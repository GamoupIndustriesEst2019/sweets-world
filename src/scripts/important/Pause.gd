extends Node2D

func _process(_delta):
	$PauseLayer/Screen.visible = get_tree().paused
	$PauseLayer/Text.visible = get_tree().paused
