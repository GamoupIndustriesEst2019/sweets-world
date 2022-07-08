extends Node2D

enum {
	MenuMain,
	MenuLoad
}

onready var maincurs = $MainMenuPanel/Cursor
onready var loadcurs = $LoadMenu/LoadPanel/Cursor
onready var loadmenu = $LoadMenu
onready var loadcont = $LoadMenu/LoadPanel/SaveFiles

onready var timer = $Timer

var mainmenu = MenuMain

var f = File.new()
var dir = Directory.new()

func _process(_delta):
	maincurs.visible = true
	maincurs.movable = mainmenu == MenuMain
	
	loadmenu.visible = mainmenu == MenuLoad
	loadcurs.movable = loadmenu.visible
	
	for save in loadcont.get_child_count():
		if dir.file_exists("user://save%s.sws" % save):
			f.open("user://save%s.sws" % save, File.READ)
			var file_data = parse_json(f.get_as_text())
			loadcont.get_child(save).get_node("SaveName").text = "Save File %s" % (save + 1)
			loadcont.get_child(save).get_node("PM1Name").text = file_data.pms["pm1"].name
			loadcont.get_child(save).get_node("Currency").text = "Ora: %s" % file_data.currency
			loadcont.get_child(save).get_node("Steps").text = "Steps: %s" % file_data.steps
			loadcont.get_child(save).get_node("Scene").text = "Scene: %s" % file_data.scene_name
			var keys = 0
			for key in ImportantStuff.keys:
				if key:
					keys += 1
			loadcont.get_child(save).get_node("Keys").text = "Keys: %s" % keys
		else:
			loadcont.get_child(save).get_node("SaveName").text = "Empty File %s" % (save + 1)
			loadcont.get_child(save).get_node("PM1Name").text = ""
			loadcont.get_child(save).get_node("Currency").text = ""
			loadcont.get_child(save).get_node("Steps").text = ""
			loadcont.get_child(save).get_node("Scene").text = ""
			loadcont.get_child(save).get_node("Keys").text = ""

func _input(event):
	if event.is_action_pressed("confirm") and ScreenStuff.screen_fade.color.a == 0:
		match mainmenu:
			MenuMain:
				match maincurs.v_id:
					0:
						ImportantStuff.startGame()
					1:
						mainmenu = MenuLoad
			MenuLoad:
				if dir.file_exists("user://save%s.sws" % loadcurs.v_id):
					ImportantStuff.loadGame(loadcurs.v_id)
				else:
					AudioManager.playSound(SoundPaths.Wrong)
	elif event.is_action_pressed("cancel") and ScreenStuff.screen_fade.color.a == 0:
		match mainmenu:
			MenuMain:
				ScreenStuff.fadeOut(Color(0, 0, 0, 1), 0.5)
				yield(ScreenStuff, "fade_out_done")
				var _s = get_tree().change_scene("res://scenes/scenes/Title.tscn")
				ScreenStuff.fadeIn(Color(0, 0, 0, 1), 0.5)
			MenuLoad:
				mainmenu = MenuMain
