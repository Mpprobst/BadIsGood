extends Node2D

@export var next_level: PackedScene
@onready var level_completed = $CanvasLayer/LevelCompleted

@export var player : PlayerController
@export var corpse : PackedScene
@export var corpses : Node

func _ready():
	Events.level_completed.connect(show_level_completed)
	player.player_died.connect(spawn_corpse)
	
func show_level_completed():
	level_completed.show()
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
	
	#get_tree().paused = true
	
func spawn_corpse(pos, rot):
	var body = corpse.instantiate()
	corpses.add_child(body)
	body.position = pos
	body.rotation = rot
