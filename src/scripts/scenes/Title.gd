extends Node2D

onready var anim = $Anim
onready var timer = $Timer

var z_pressed = false

func _ready():
	$PressZ.visible = false
	timer.start(2.25)

func onTimerTimeout():
	if !z_pressed:
		anim.play("press z")

func _input(event):
	if event.is_action_pressed("confirm") and !z_pressed:
		z_pressed = true
		anim.play("flash text")
		yield(anim, "animation_finished")
		timer.start(1)
		yield(timer, "timeout")
		ScreenStuff.fadeOut(Color(0, 0, 0, 1), 0.5)
		yield(ScreenStuff, "fade_out_done")
		var _s = get_tree().change_scene("res://scenes/scenes/MainMenu.tscn")
		ScreenStuff.fadeIn(Color(0, 0, 0, 1), 0.5)
