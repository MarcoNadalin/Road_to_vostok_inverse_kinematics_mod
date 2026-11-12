extends Node3D

class_name IKWeaponSkeleton

const IK_TWO_BONE = preload("res://mods/InverseKinematicsRig/IKTwoBone.gd")

@export var skeleton: Skeleton3D

var is_initialized := false

const REQUIRED_BONES := [
	"Arm_Upper_R", "Arm_Lower_R", "Wrist_R",
	"Arm_Upper_L", "Arm_Lower_L", "Wrist_L"
]

var body_index := -1
var weapon_root_indices: Array[int] = []
# right arm bones
var wrist_r_index := -1
var shoulder_r_index := -1
var elbow_r_index := -1

# left arm bones
var wrist_l_index := -1
var shoulder_l_index := -1
var elbow_l_index := -1

func _ready() -> void:
	if skeleton == null:
		push_error("Assign Skeleton in the Inspector.")
		return

	for bone_name in REQUIRED_BONES:
		if skeleton.find_bone(bone_name) == -1:
			push_error("Missing bone: " + bone_name)
			return

	body_index = find_weapon_body_bone_index()
	
	if body_index == -1:
		push_error("Could not find weapon body bone.")
		return

	# ensure weapon internals follow rig
	weapon_root_indices.clear()
	var weapon_prefix := skeleton.get_bone_name(body_index).trim_suffix("_Body") + "_"
	for index in skeleton.get_bone_count():
		if index != body_index and skeleton.get_bone_parent(index) == -1:
			if skeleton.get_bone_name(index).begins_with(weapon_prefix):
				weapon_root_indices.append(index)
	
	
	# right arm bones
	wrist_r_index = skeleton.find_bone("Wrist_R")
	shoulder_r_index = skeleton.find_bone("Arm_Upper_R")
	elbow_r_index = skeleton.find_bone("Arm_Lower_R")
	
	# left arm bones
	wrist_l_index = skeleton.find_bone("Wrist_L")
	shoulder_l_index = skeleton.find_bone("Arm_Upper_L")
	elbow_l_index = skeleton.find_bone("Arm_Lower_L")

	is_initialized = true
	
func apply_weapon_pose(target_in_skeleton: Transform3D) -> void:
	if !is_initialized:
		return
	
	var current_body_pose = skeleton.get_bone_global_pose(body_index)
	var current_wrist_r_pose = skeleton.get_bone_global_pose(wrist_r_index)
	var current_wrist_l_pose = skeleton.get_bone_global_pose(wrist_l_index) 
	
	var current_right_grip = current_body_pose.affine_inverse() * current_wrist_r_pose
	var current_left_grip = current_body_pose.affine_inverse() * current_wrist_l_pose
	
	#calculate new wrist position to stay with gun
	var desired_wrist_r_pose = target_in_skeleton * current_right_grip
	var desired_wrist_l_pose = target_in_skeleton * current_left_grip

	var weapon_delta := target_in_skeleton * current_body_pose.affine_inverse()
	var rotation_delta := weapon_delta.basis.orthonormalized().get_rotation_quaternion()
	for index in weapon_root_indices:
		# ensure weapon internals follow rig
		var part_position := skeleton.get_bone_pose_position(index)
		var part_rotation := skeleton.get_bone_pose_rotation(index)
		skeleton.set_bone_pose_position(index, weapon_delta * part_position)
		skeleton.set_bone_pose_rotation(index, (rotation_delta * part_rotation).normalized())
	
	skeleton.set_bone_global_pose(body_index, target_in_skeleton)
	IK_TWO_BONE.solve(skeleton, shoulder_r_index, elbow_r_index, wrist_r_index, desired_wrist_r_pose)
	IK_TWO_BONE.solve(skeleton, shoulder_l_index, elbow_l_index, wrist_l_index, desired_wrist_l_pose)
	
func find_weapon_body_bone_index() -> int:	
	var found_index = -1
	for bone_index in range(skeleton.get_bone_count()):
		var bone_name = skeleton.get_bone_name(bone_index)
		if(bone_name.ends_with("_Body")):
			if(found_index != -1):
				push_error("Multiple body bones found")
				return -1
			
			found_index = bone_index
		
	return found_index
	
