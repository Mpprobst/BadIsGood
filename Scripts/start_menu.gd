extends CenterContainer

@onready var crash_sfx : AudioStreamPlayer2D = $Crash
@onready var ship : AnimatedSprite2D = $Ship

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	if ship != null:
		ship.play("default")

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	crash_sfx.play()
	await get_tree().create_timer(7.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/Main.tscn")

	LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()
