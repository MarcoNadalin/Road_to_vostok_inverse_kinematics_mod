extends RefCounted

class_name IKRig

const IK_WEAPON_SKELETON = preload("res://mods/InverseKinematicsRig/IKWeaponSkeleton.gd")
const EFFECT_COORDINATOR = preload("res://mods/InverseKinematicsRig/WeaponEffectCoordinator.gd")
const IK_WEAPON_MODIFIER = preload("res://mods/InverseKinematicsRig/IKWeaponModifier.gd")

var skeleton : Skeleton3D
var weapon_skeleton : IK_WEAPON_SKELETON
var coordinator : EFFECT_COORDINATOR
var modifier : IK_WEAPON_MODIFIER
var exit_callback : Callable
