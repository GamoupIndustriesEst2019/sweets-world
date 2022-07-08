extends Camera2D

var cam_zoom = 0.5
var target = null

func _process(_delta):
	if ImportantStuff.node_in_groups(get_tree().current_scene, ["world", "town", "room", "dungeon"]) and target != null:
		position = target.position + Vector2(10, 6)
		zoom = Vector2(cam_zoom, cam_zoom)
	else:
		position = Vector2(ProjectSettings.get("display/window/size/width") / 2, ProjectSettings.get("display/window/size/height") / 2)
		zoom = Vector2.ONE
	
	if ImportantStuff.node_in_groups(get_tree().current_scene, ["room", "dungeon"]):
		limit_left = get_tree().current_scene.get_node("Map").limit_pos.x
		limit_top = get_tree().current_scene.get_node("Map").limit_pos.y
		limit_right = get_tree().current_scene.get_node("Map").limit_size.x
		limit_bottom = get_tree().current_scene.get_node("Map").limit_size.y
	elif get_tree().current_scene.is_in_group("world"):
		pass
