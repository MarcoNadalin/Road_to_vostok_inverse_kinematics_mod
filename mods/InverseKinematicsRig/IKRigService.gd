extends Node

class_name IKRigService

const IK_WEAPON_SKELETON = preload("res://mods/InverseKinematicsRig/IKWeaponSkeleton.gd")
const EFFECT_COORDINATOR = preload("res://mods/InverseKinematicsRig/WeaponEffectCoordinator.gd")
const IK_WEAPON_MODIFIER = preload("res://mods/InverseKinematicsRig/IKWeaponModifier.gd")
const IK_RIG = preload("res://mods/InverseKinematicsRig/IKRig.gd")

signal rig_registered(rig_id: int, rig_entry: IK_RIG)
signal rig_unregistered(rig_id: int)

var _rigs : Dictionary[int, IK_RIG] = {}


func register_rig(skeleton: Skeleton3D) -> IK_RIG:
	if is_instance_valid(skeleton) == false:
		return null
	
	if skeleton.is_inside_tree() == false:
		return null 
	
	var rig_id = skeleton.get_instance_id()
	
	if _rigs.has(rig_id):
		return _rigs[rig_id]
	
	var ik_weapon_skeleton = IK_WEAPON_SKELETON.new()
	ik_weapon_skeleton.skeleton = skeleton
	
	add_child(ik_weapon_skeleton)
	
	if ik_weapon_skeleton.is_initialized == false:
		ik_weapon_skeleton.queue_free()
		return null
	
	var coordinator := EFFECT_COORDINATOR.new()
	
	ik_weapon_skeleton.add_child(coordinator)
	
	var modifier := IK_WEAPON_MODIFIER.new()
	
	modifier.ik_weapon_skeleton = ik_weapon_skeleton
	
	skeleton.add_child(modifier)
	
	var rig_entry := IK_RIG.new()
	rig_entry.skeleton = skeleton
	rig_entry.weapon_skeleton = ik_weapon_skeleton
	rig_entry.coordinator = coordinator
	rig_entry.modifier = modifier
	
	_rigs[rig_id] = rig_entry
	
	#hook up to scene callbacks to know when skeleton has left the scene
	var exit_callback = _on_skeleton_tree_exited.bind(rig_id)
	
	rig_entry.exit_callback = exit_callback
	
	skeleton.tree_exited.connect(exit_callback, CONNECT_DEFERRED)
	
	rig_registered.emit(rig_id, rig_entry)
	return rig_entry

func unregister_rig(rig_id: int) -> void:
	if _rigs.has(rig_id) == false:
		return
		
	var rig = _rigs[rig_id]
	var skeleton = rig.skeleton
	var exit_callback = rig.exit_callback
	var effect_coordinator = rig.coordinator
	
	if is_instance_valid(skeleton):
		if skeleton.tree_exited.is_connected(exit_callback):
			skeleton.tree_exited.disconnect(exit_callback)
	
	if is_instance_valid(effect_coordinator):
		effect_coordinator.clear_effects()
	
	_rigs.erase(rig_id)
	rig_unregistered.emit(rig_id)
	var ik_modifier = rig.modifier
	var controller = rig.weapon_skeleton
	
	if is_instance_valid(ik_modifier):
		ik_modifier.queue_free()
	
	if is_instance_valid(controller):
		controller.queue_free()

func get_registered_rigs() -> Dictionary[int, IK_RIG]:
	return _rigs.duplicate(true)

func _on_skeleton_tree_exited(rig_id: int) -> void:
	if _rigs.has(rig_id) == false:
		return
		
	var rig = _rigs[rig_id]
	
	var skeleton = rig.skeleton
	
	if is_instance_valid(skeleton) and skeleton.is_inside_tree():
		return
	
	unregister_rig(rig_id)
	
	
