class_name MovingPlatform

extends AnimatableBody2D
var body : AnimatableBody2D
@export var duration = 5
@export var offset = Vector2(0, 300)

@onready var sfx : AudioStreamPlayer2D = $Hover
@onready var animator : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	offset.y = -offset.y # its flipped for some reason
	body = get_node(".")
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	var start_pos = position
	var end_pos = start_pos + offset

	tween.tween_property(body, "position", end_pos, duration / 2.0)
	tween.tween_property(body, "position", start_pos, duration / 2.0)

	if sfx != null:
		sfx.max_distance = floor(offset.length())
		
	if animator != null:
		animator.play("hover")
		
	var sprite_anim = get_node("Node2D/AnimatedSprite2D")
	if sprite_anim != null:
		sprite_anim.play("default")


