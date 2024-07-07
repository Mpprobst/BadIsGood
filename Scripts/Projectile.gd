class_name Projectile

extends Area2D

@export var speed = 500.0
var dir : Vector2

@export var shot_sounds : Array[AudioStream]

# Called when the node enters the scene tree for the first time.
func _ready():
	# pick a random effect sound
	var shot_player = get_node("ShotSound")
	var rng = RandomNumberGenerator.new()
	var clip_idx = rng.randi_range(0, len(shot_sounds)-1)
	shot_player.stream = shot_sounds[clip_idx]
	shot_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# when we collide we need to destroy this and damage the player
	global_position += dir * speed * delta 

func _on_body_entered(body):
	print("projectile hit %s" % body.name)
	var impact_audio = get_node("Impact")
	var game : Game = get_tree().get_root().get_node("Level")
	print("root %s" % game.name)
	var impact_effect = game.level_sfx.get_rand_impact()
	# change hit sfx based on what is hit
	if body.is_in_group("player"):
		var player : PlayerController = body
		player.kill()
		impact_effect = game.level_sfx.get_rand_flesh()
		
	# hit effect 
	# sound effect
	#queue_free()
	impact_audio.stream = impact_effect
	$AnimationPlayer.play("impact")

# hurls this projectile in the given direction
func launch(pos, modifier):
	var direction = pos - global_position
	dir = direction.normalized()
	speed = speed * modifier
	look_at(pos)
	# set direction angle
