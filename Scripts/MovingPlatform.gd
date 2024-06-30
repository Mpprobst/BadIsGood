extends Node2D

@export var body : AnimatableBody2D
@export var duration = 5
@export var offset = Vector2(0, 300)

# Called when the node enters the scene tree for the first time.
func _ready():
	#offset.y = -offset.y # its flipped for some reason
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	var start_pos = position
	var end_pos = start_pos + offset
	
	tween.tween_property(body, "position", start_pos, duration / 2)
	tween.tween_property(body, "position", end_pos, duration / 2)


