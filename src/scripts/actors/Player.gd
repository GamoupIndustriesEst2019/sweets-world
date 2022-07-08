extends Actor

func _physics_process(delta):
	$Body/Raycast.enabled = !Input.is_key_pressed(KEY_CONTROL) and OS.is_debug_build()
	
	if movable:
		for dir in dirs:
			if !get_node("Body/Tween").is_active():
				if Input.is_action_pressed(dir):
					move(dir, delta)
					yield(tween, "tween_all_completed")
					if get_tree().current_scene.is_in_group("world"):
						PlayerStuff.steps += 1
						if ImportantStuff.odds(1, 75):
							ImportantStuff.startBattle()
					elif get_tree().current_scene.is_in_group("dungeon"):
						if ImportantStuff.odds(1, get_tree().current_scene.enc_rate):
							ImportantStuff.startBattle()
					if !PlayerStuff.no_statuses():
						PlayerStuff.inflictStatuses()
						statusFlash(PlayerStuff.pms[0].statuses[0])
				if Input.is_action_just_pressed("menu") and !Input.is_action_pressed(dir):
					$Menu.open()
			else:
				if Input.is_action_just_pressed("menu"):
					yield(tween, "tween_all_completed")
					$Menu.open()

func statusFlash(status: String):
	var tween = Tween.new()
	add_child(tween)
	
	if status == "poison":
		tween.interpolate_property($Graphic/Sprite.material, "shader_param/solid_color", Color(0, 1, 0, 0.48), Color(0, 1, 0, 0), 0.125)
		tween.start()
