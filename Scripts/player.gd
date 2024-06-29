class_name PlayerController

extends CharacterBody2D

@export var movement_data : PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.

var air_jump = false
var just_wall_jumped = false
var dying = false
var dead = false
var input_actions = ["Move_Left", "Move_Right", "Jump"]
var used_buttons = []

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position

var move_val = 0
var has_moved_left = false
var has_moved_right = false
var waiting_for_map = false

signal player_died

func _ready():
	reset()

func reset():
	dying = false
	dead = false
	rotation = 0
	global_position = starting_position
	input_actions = ["Move_Left", "Move_Right", "Jump"]
	used_buttons = []
	velocity = Vector2.ZERO
	move_val = 0
	has_moved_left = false
	has_moved_right = false
	
	for action in input_actions:
		InputMap.action_erase_events(action)
		
	# TODO: set the kill key to some random key? small chance players just kill themselves

func _unhandled_key_input(event):
	if dying or dead:
		return
		
	# this here becuase input detection is paused for a few frames 
	if not has_moved_left and not input_actions.has("Move_Left"):
		has_moved_left = true
		waiting_for_map = false
	elif not has_moved_right and not input_actions.has("Move_Right"):
		has_moved_right = true
		waiting_for_map = false
	
	if event.is_pressed() and len(input_actions) > 0 and not used_buttons.has(event.as_text()):
		# set an input randomly
		var rand = randi_range(0, len(input_actions)-1)
		var action = input_actions[rand]
		InputMap.action_add_event(action, event)
		# physics_process wont be called here 
		if action == "Jump":
			handle_jump()
		elif action == "Move_Left":
			move_val = -1
		elif action == "Move_Right":
			move_val = 1
			
		print("map " + event.as_text() + " to " + action)
		input_actions.remove_at(rand) 
		used_buttons.append(event.as_text())
		
		# TODO: play sfx like a robot serv

func _physics_process(delta):
	apply_gravity(delta)
	if Input.is_action_just_pressed("Kill"):
		kill()
		
	if not dying and not dead:
		if Input.is_action_just_pressed("Jump"):
			handle_wall_jump()
			handle_jump()
		
		# if we have moved left or right, left or right is still unmapped, and the move val has gone back to 0,
		# then we know we are about remap the other shit
		if (has_moved_left or has_moved_right) and move_val == 0 and (input_actions.has("Move_Left") or input_actions.has("Move_Right")):
			waiting_for_map = true 
			
		var input_val = Input.get_axis("Move_Left", "Move_Right")
		# result of this following complex logic is to keep moving in the direction as the new input is mapped
		# while allowing player to stop when the input map update completes
		# separated into two ifs because we don't know which direction will be mapped first
		if (has_moved_left and input_val <= 0):		# input map is ready, allow idle or left movement
			if not waiting_for_map or move_val != 1:# only allows idle or left while configuring right input
				move_val = input_val
		elif (has_moved_right and input_val >= 0):	# read comments above, replacing left for right
			if not waiting_for_map or move_val != -1:
				move_val = input_val
		
		handle_acceleration(move_val, delta)
	elif is_on_floor() and not dead:
		die()
		return
		
	handle_air_acceleration(move_val, delta)
	apply_friction(move_val, delta)
	apply_air_resistance(move_val, delta)
	update_animations(move_val)	
	move_and_slide()
	var was_on_floor = is_on_floor()

	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false

func move(input_axis, delta):
	handle_acceleration(input_axis, delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	
	velocity.x = wall_normal.x * movement_data.speed
	velocity.y = movement_data.jump_velocity
	just_wall_jumped = true
	
func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if  velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
			
		if air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		# (Old code used here) velocity.x = direction * SPEED

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		# (Old code used here)velocity.x = move_toward(velocity.x, 0, SPEED)
		# Or just set velocity.x = 0 for simplicities sake!

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("Jump")
		# This overrides other animations if we are in air

func _on_hazard_detector_area_entered(area):
	die()
	
func kill():
	# this is getting called a bunch
	if dying:	# double killed do die
		die()
	move_val = 0
	dying = true
	rotation = deg_to_rad(90)	# TODO: this based on damage direction

func die():
	if dead:
		return
	print("die")
	dead = true
	move_val = 0
	rotation = deg_to_rad(90)	# TODO: this based on if there is a wall in front
	await get_tree().create_timer(1.0).timeout
	player_died.emit(global_position, rotation)
	reset()
	# TODO: bug here where we can start on top of a corpse
