extends RefCounted
class_name IKTwoBone

static func solve(
	skeleton: Skeleton3D, 
	shoulder_index: int,
	elbow_index: int, 
	wrist_index: int, 
	target_pose: Transform3D
) -> void:
	var shoulder_pose = skeleton.get_bone_global_pose(shoulder_index)
	var elbow_pose = skeleton.get_bone_global_pose(elbow_index)
	var wrist_pose = skeleton.get_bone_global_pose(wrist_index)
	
		## START IK CALCULATIONS FOR SHOULDER

	#Calculate Upper arm length (distance from shoulder to elbow)
	var upper_arm_length = shoulder_pose.origin.distance_to(elbow_pose.origin) # a
	#calculate forearm length
	var forearm_length = elbow_pose.origin.distance_to(wrist_pose.origin) # b
	#calculate target distance (distance from shoulder to desired wrist
	var target_distance = shoulder_pose.origin.distance_to(target_pose.origin) # d
	
	# ensure target is within reach
	var reach_margin := 0.0001
	var minimum_reach = abs(upper_arm_length - forearm_length) + reach_margin
	var maximum_reach = upper_arm_length + forearm_length - reach_margin
	var clamped_target_distance = clampf(target_distance, minimum_reach, maximum_reach)
	
	#direction from shoulder towards desired wrist
	var direction = (target_pose.origin - shoulder_pose.origin).normalized()
	var reachable_wrist_position = shoulder_pose.origin + direction * clamped_target_distance
	#calculate along length
	var elbow_projection_distance = (pow(upper_arm_length, 2) + pow(clamped_target_distance, 2) - 
		pow(forearm_length, 2)) / (2 * clamped_target_distance)
	
	# calculate length of line from elbow to along
	var elbow_height = sqrt(pow(upper_arm_length, 2) - pow(elbow_projection_distance, 2))
	
	#calculate end point of projection distance vector
	var projection_point = shoulder_pose.origin + direction * elbow_projection_distance
	
	#calculate vector from shoulder to current elbow pose
	var current_elbow_offset = elbow_pose.origin - shoulder_pose.origin
	
	#calculate dot product with normalised direction
	var current_elbow_axis_distance = current_elbow_offset.dot(direction)
	
	var parallel_component = direction * current_elbow_axis_distance
	var perpendicular_component = current_elbow_offset - parallel_component
	var bend_direction = perpendicular_component.normalized()
	
	var desired_elbow_position = projection_point + bend_direction * elbow_height
	
	#rotate upper-arm bone
	var desired_upper_arm_offset = desired_elbow_position - shoulder_pose.origin
	var current_upper_arm_direction = current_elbow_offset.normalized()
	var desired_upper_arm_direction = desired_upper_arm_offset.normalized()
	var upper_arm_rotation_delta = Quaternion(current_upper_arm_direction, desired_upper_arm_direction)
	var upper_arm_rotation_basis = Basis(upper_arm_rotation_delta)
	var desired_shoulder_pose = shoulder_pose
	desired_shoulder_pose.basis = upper_arm_rotation_basis * shoulder_pose.basis
	
	## END IK CALCULATIONS FOR SHOULDER
	
	# UPDATE SHOULDER BONE
	skeleton.set_bone_global_pose(shoulder_index, desired_shoulder_pose)
	
	## START IK CALCULATIONS FOR FOREARM
	
	var updated_elbow_pose = skeleton.get_bone_global_pose(elbow_index)
	var updated_wrist_pose = skeleton.get_bone_global_pose(wrist_index)
	
	var current_forearm_direction = (updated_wrist_pose.origin - updated_elbow_pose.origin).normalized()
	var desired_forearm_direction = (reachable_wrist_position - updated_elbow_pose.origin).normalized()
	
	var forearm_rotation_delta = Quaternion(current_forearm_direction, desired_forearm_direction)
	var forearm_basis = Basis(forearm_rotation_delta)
	var desired_forearm_pose = updated_elbow_pose
	desired_forearm_pose.basis = forearm_basis * updated_elbow_pose.basis
	
	## END IK CALCULATION FOR FOREARM
	
	# UPDATE FOREARM BONE
	skeleton.set_bone_global_pose(elbow_index, desired_forearm_pose)
	
	## START IK CALCULATION FOR WRIST
	
	updated_wrist_pose = skeleton.get_bone_global_pose(wrist_index)
	updated_wrist_pose.basis = target_pose.basis
	
	## END IK CALCULATION FOR WRIST
	
	# UPDATE WRIST BONE
	skeleton.set_bone_global_pose(wrist_index, updated_wrist_pose)
