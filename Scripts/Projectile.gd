class_name Projectile

extends Area2D

@export var speed = 500.0
var dir : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# when we collide we need to destroy this and damage the player
	position += dir * speed * delta 

func _on_body_entered(body):
	print("projectile hit %s" % body.name)
	if body.is_in_group("player"):
		var player : PlayerController = body
		player.kill()
		
	# hit effect 
	# sound effect
	queue_free()

# hurls this projectile in the given direction
func launch(direction):
	dir = direction.normalized()
