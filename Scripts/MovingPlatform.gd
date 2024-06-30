extends Node2D

@export var speed = 1
@export var length = 5
@export var direction = Vector2.RIGHT

var start_pos : Vector2
var end_pos : Vector2
var goal : Vector2
var min_dist = 1	# how close to positions do we have to get

var end = -1	#-1 means a start point, +1 means at end point

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	end_pos = start_pos + direction * length
	goal = end_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var move = position.move_toward(goal, speed * delta)
	if move.distance_to(goal) <= min_dist:
		move = goal
		end *= -1
		if end == 1:
			goal = end_pos
		else:
			goal = start_pos
	

