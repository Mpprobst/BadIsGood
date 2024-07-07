extends Area2D

func _ready():
	$AnimationPlayer.play("idle")

func _on_body_entered(body):
	$AnimationPlayer.play("pickup")
	var hearts = get_tree().get_nodes_in_group("Hearts")
	if hearts.size() == 1:
		Events.level_completed.emit()
