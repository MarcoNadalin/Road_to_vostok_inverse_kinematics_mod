extends Node

const RIG_SERVICE = preload("res://mods/InverseKinematicsRig/IKRigService.gd")

var rig_service : RIG_SERVICE

var mod_lib = null

const _MOD_LIB := "RTVModLib"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rig_service = RIG_SERVICE.new()
	add_child(rig_service)
	print("Created IK Rig Service")
	process_priority = 1000
	if Engine.has_meta(_MOD_LIB):
		mod_lib = Engine.get_meta(_MOD_LIB)
	else:
		print("Metro Mod Loader is not available.")
		return
	
	if mod_lib._is_ready == true:
		_on_frameworks_ready()
	else:
		mod_lib.frameworks_ready.connect(_on_frameworks_ready)

func _process(delta: float) -> void:
	if is_instance_valid(rig_service) == false:
		return
	
	var registered_rigs = rig_service.get_registered_rigs()
	
	for rig_id in registered_rigs:
		var current_rig = registered_rigs[rig_id]
		var skeleton = current_rig.skeleton
		var coordinator = current_rig.coordinator
		var modifier = current_rig.modifier
		
		if is_instance_valid(skeleton) == false:
			continue
			
		if skeleton.is_inside_tree() == false:
			continue
				
		if is_instance_valid(coordinator) == false:
			continue
		
		if is_instance_valid(modifier) == false:
			continue
		
		var offset = coordinator.compose_offset(delta)
		modifier.submit_offset(offset)

func _on_frameworks_ready() -> void:
	mod_lib.hook("weaponrig-_ready-post", _on_weapon_ready)

func _on_weapon_ready() -> void:
	var weapon_rig = mod_lib._caller
	
	if is_instance_valid(weapon_rig) == false:
		return
	
	var weapon_skeleton = weapon_rig.skeleton
	
	if is_instance_of(weapon_skeleton, Skeleton3D):
		var rig_entry = rig_service.register_rig(weapon_skeleton)
		
		if is_instance_valid(rig_entry):
			print("Successfully registered IK rig!")
