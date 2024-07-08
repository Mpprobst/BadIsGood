extends Node2D

@export var range = 24.0
@export var fire_rate = 1.0
@export var shot_speed_mod = 1.0
@export var projectile_scene : PackedScene
var animator : AnimatedSprite2D
@export var shot_offset : Vector2
@export var target_offset : Vector2

var target : Node2D
var fire_cooldown : float

var in_range = false

@onready var servo_audio : AudioStreamPlayer2D = $Servo
@export var servo_up_clip : AudioStream
@export var servo_down_clip : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	# find the player
	var players = get_tree().get_nodes_in_group("player")
	if len(players) > 0:
		target = players[0]
	shot_offset.y *= -1
	target_offset.y *= -1
	animator = $AnimatedSprite2D
	servo_audio.max_distance = floor(range) + 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target == null:
		return
	# check if player is in range
	# start firing 
	fire_cooldown -= delta
	#print(global_position.distance_to(target.global_position))
	if global_position.distance_to(target.global_position) < range:
		if not in_range:
			servo_audio.stream = servo_up_clip
			servo_audio.play()
			animator.play("Activation", 2)
			in_range = true
			print("player in range")
		if fire_cooldown <= 0 && animator.frame == 12:
			fire()
	elif in_range:
		animator.play("Activation", -2)
		in_range = false
		print("player exit range")
		servo_audio.stream = servo_down_clip
		servo_audio.play()
			
			
func fire():
	print("fire!")
	fire_cooldown = fire_rate
	# spawn projectile
	var projectile : Projectile = projectile_scene.instantiate()
	add_child(projectile)
	var launch_pos = global_position + shot_offset
	var lookahead = 0.25
	var target_pos = target.global_position + target_offset + target.velocity * Vector2(lookahead,lookahead)
	
	print("pos %s" % global_position)
	print("offset %s" % launch_pos)
	projectile.launch(target_pos, shot_speed_mod)
	projectile.global_position = launch_pos

