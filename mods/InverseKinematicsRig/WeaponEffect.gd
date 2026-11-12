extends Node
class_name WeaponEffect

@export var enabled : bool = true

var offset : Transform3D = Transform3D.IDENTITY
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_effect(_delta: float) -> void:
	pass

func get_offset() -> Transform3D:
	if enabled:
		return offset
	else:
		return Transform3D.IDENTITY

func reset_effect() -> void:
	offset = Transform3D.IDENTITY
