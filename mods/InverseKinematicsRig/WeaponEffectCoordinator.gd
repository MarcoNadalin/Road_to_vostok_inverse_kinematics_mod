extends Node

class_name WeaponEffectCoordinator

const EFFECT = preload("res://mods/InverseKinematicsRig/WeaponEffect.gd")

var _effects : Array[EFFECT] = []

func compose_offset(delta: float) -> Transform3D:
	var final_pose = Transform3D.IDENTITY
	
	for effect in _effects:
		if is_instance_valid(effect):
			effect.update_effect(delta)
			final_pose *= effect.get_offset()
	
	return final_pose
	
func register_effect(effect : EFFECT) -> void:
	if is_instance_valid(effect) == false:
		return
	
	if _effects.has(effect):
		return
	
	_effects.append(effect)

func unregister_effect(effect: EFFECT) -> void:
	if is_instance_valid(effect) == false:
		return
	
	if _effects.has(effect):
		_effects.erase(effect)

func clear_effects() -> void:
	for effect in _effects:
		if is_instance_valid(effect):
			effect.reset_effect()
		
	_effects.clear()
