extends CanvasLayer

func _process(_delta):
	for i in get_children():
		i.visible = OS.get_name() in ["Android"]
