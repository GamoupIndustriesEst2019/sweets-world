extends Node2D

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(_delta):
	if Input.is_action_just_pressed("fs_toggle"):
		ImportantStuff.toggleFullscreen()
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
