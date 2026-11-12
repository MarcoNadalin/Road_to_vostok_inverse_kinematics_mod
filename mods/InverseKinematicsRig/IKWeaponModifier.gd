extends SkeletonModifier3D

class_name IKWeaponModifier

const IK_WEAPON_SKELETON = preload("res://mods/InverseKinematicsRig/IKWeaponSkeleton.gd")

@export var ik_weapon_skeleton : IK_WEAPON_SKELETON

var effect_offset := Transform3D.IDENTITY
var has_effect_offset := false

func submit_offset(pose: Transform3D) -> void:
	effect_offset = pose
	has_effect_offset = true

func _process_modification() -> void:
	if is_instance_valid(ik_weapon_skeleton) == false:
		return
	
	if ik_weapon_skeleton.is_initialized == false:
		return
	
	if has_effect_offset == false:
		return
	
	if effect_offset.is_equal_approx(Transform3D.IDENTITY):
		return
	
	var current_body_pose = ik_weapon_skeleton.skeleton.get_bone_global_pose(ik_weapon_skeleton.body_index)
	ik_weapon_skeleton.apply_weapon_pose(current_body_pose * effect_offset)
