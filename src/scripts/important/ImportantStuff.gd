extends Node

signal cs_done

var key1: bool = true
var key2: bool = false
var key3: bool = false
var key4: bool = false

var keys: Array

var touchscreen: bool = false

var data: Dictionary = {
	"keys": [],
	"pms": {},
	"currency": 0,
	"steps": 0,
	"scene_name": "Test",
	"tiles": [{
		"x": 0,
		"y": 0,
		"direction": "down"
	}]
}

var start_scene = "Test"
var start_pos   = Vector2(15, 12)

func _ready():
	if OS.get_name() in ["Android"]:
		touchscreen = true
		
	else:
		touchscreen = false

func _process(_delta):
	keys = [
		key1,
		key2,
		key3,
		key4
	]
	
	data.pms.clear()
	for pm in PlayerStuff.pms.size():
		data.pms["pm%s" % (pm + 1)] = {
			"name": PlayerStuff.pms[pm].name,
			"hp": PlayerStuff.pms[pm].hp,
			"maxhp": PlayerStuff.pms[pm].maxhp,
			"sp": PlayerStuff.pms[pm].sp,
			"maxsp": PlayerStuff.pms[pm].maxsp,
			"inv": [],
			"equipment": {
				"right": "",
				"left": "",
				"head": "",
				"body": "",
				"legs": "",
				"accessory": ""
			}
		}
		for item in 18:
			if item < PlayerStuff.pms[pm].inv.size():
				var itemname = PlayerStuff.pms[pm].inv[item].name
				itemname = itemname.replace(" ", "")
				data.pms["pm%s" % (pm + 1)].inv.append(itemname)
		
		for equipment in PlayerStuff.pms[pm].equipment.keys():
			if PlayerStuff.pms[pm].equipment[equipment] != null:
				var equname = PlayerStuff.pms[pm].equipment[equipment].name
				equname = equname.replace(" ", "")
				data.pms["pm%s" % (pm + 1)].equipment[equipment] = equname
	
	data.currency = PlayerStuff.currency
	data.steps = PlayerStuff.steps
	data.scene_name = get_tree().current_scene.name
	data.keys = keys
	
	if node_in_groups(get_tree().current_scene, ["world", "town", "dungeon", "room"]):
		data.tiles[0].x = get_tree().current_scene.get_node("Actors/Player").position.x / 20
		data.tiles[0].y = get_tree().current_scene.get_node("Actors/Player").position.y / 20
		data.tiles[0].direction = get_tree().current_scene.get_node("Actors/Player").anim_dir

func node_in_groups(node: Node, groups: Array) -> bool:
	for group in groups:
		if node.is_in_group(group):
			return true
	return false

func startCutscene(id: String, args: Array = []) -> void:
	var cutscene = load("res://src/events/%s%s.gd" % [get_tree().current_scene.name, id]).new()
	cutscene.startCutscene(args)
	emit_signal("cs_done")

func toggleFullscreen() -> void:
	OS.window_fullscreen = !OS.window_fullscreen

func var_type_in_array(variable, array: Array) -> bool:
	for i in array:
		if variable is i:
			return true
	return false

func array_only_one_type(array: Array, type) -> bool:
	for variable in array:
		if !(variable is type):
			return false
	return true

func startBattle():
	if !get_tree().current_scene.is_in_group("battle"):
		# File Stuff
		var f = File.new()
		f.open("res://assets/data/troops.json", File.READ)
		var json = parse_json(f.get_as_text())
		
		# RNG Stuff
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		# Battle Stuff
		for extra in range(BattleStuff.current_troop.size()):
			BattleStuff.current_troop.remove(0)
		
		

func saveGame(slot: int):
	var f = File.new()
	f.open("user://save%s.sws" % slot, File.WRITE)
	f.store_string(to_json(data))

func loadGame(slot: int):
	var f = File.new()
	f.open("user://save%s.sws" % slot, File.READ)
	var file_data = parse_json(f.get_as_text())
	
	ScreenStuff.fadeOut(Color(0, 0, 0, 1), 0.5)
	yield(ScreenStuff, "fade_out_done")
	
	PlayerStuff.currency = file_data.currency
	PlayerStuff.steps = file_data.steps
	PlayerStuff.currency = file_data.currency
	for pm in file_data.pms.keys().size():
		if file_data.pms["pm%s" % (pm + 1)].name != null:
			PlayerStuff.pms[pm].name = file_data.pms["pm%s" % (pm + 1)].name
			PlayerStuff.pms[pm].hp = file_data.pms["pm%s" % (pm + 1)].hp
			PlayerStuff.pms[pm].maxhp = file_data.pms["pm%s" % (pm + 1)].maxhp
			PlayerStuff.pms[pm].sp = file_data.pms["pm%s" % (pm + 1)].sp
			PlayerStuff.pms[pm].maxsp = file_data.pms["pm%s" % (pm + 1)].maxsp
			PlayerStuff.pms[pm].inv = []
			for item in file_data.pms["pm%s" % (pm + 1)].inv:
				PlayerStuff.pms[pm].inv.append(load("res://src/resources/items/%s.tres" % item))
			
			for equipment in file_data.pms["pm%s" % (pm + 1)].equipment.keys():
				if file_data.pms["pm%s" % (pm + 1)].equipment[equipment] != "":
					PlayerStuff.pms[pm].equipment[equipment] = load("res://src/resources/items/%s.tres" % file_data.pms["pm%s" % (pm + 1)].equipment[equipment])
				else:
					PlayerStuff.pms[pm].equipment[equipment] = null
	
	var _s = get_tree().change_scene("res://scenes/scenes/%s.tscn" % file_data.scene_name)
	yield(get_tree().create_timer(0.01), "timeout")
	get_tree().current_scene.get_node("Actors/Player").position.x = file_data.tiles[0].x * 20
	get_tree().current_scene.get_node("Actors/Player").position.y = file_data.tiles[0].y * 20
	get_tree().current_scene.get_node("Actors/Player").anim_dir = file_data.tiles[0].direction
	ScreenStuff.fadeIn(Color(0, 0, 0, 1), 0.5)

func startGame():
	ScreenStuff.fadeOut(Color(0, 0, 0, 1), 0.5)
	yield(ScreenStuff, "fade_out_done")
	var _s = get_tree().change_scene("res://scenes/scenes/%s.tscn" % ImportantStuff.start_scene)
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().current_scene.get_node("Actors/Player").position = ImportantStuff.start_pos * 20
	ScreenStuff.fadeIn(Color(0, 0, 0, 1), 0.5)

func get_player_tile_pos():
	if node_in_groups(get_tree().current_scene, ["world", "room", "town", "dungeon"]):
		return get_tree().current_scene.get_node("Actors/Player").position / 20

func set_player_tile_pos(tile: Vector2):
	if node_in_groups(get_tree().current_scene, ["world", "room", "town", "dungeon"]):
		get_tree().current_scene.get_node("Actors/Player").position = tile * 20

func calculateDamage(user: Character, target: Enemy) -> int:
	# RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Damage
	var damage = rng.randi_range(3 + user.atk - target.def, 6 + user.atk - target.def)
	return damage

func chance(percentage: int) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var result = rng.randi_range(1, 100)
	return percentage >= result

func odds(number: int, odds: int) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	return rng.randi_range(number, odds) == odds
