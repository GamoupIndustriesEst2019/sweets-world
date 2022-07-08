extends TextureRect

export var menu_parent_path: NodePath
onready var menu_parent = get_node(menu_parent_path)

var v_id = 0
var h_id = 0
var g_id = Vector2.ZERO

export var movable: bool = false
export var offset: Vector2

func _process(_delta):
	if visible:
		if menu_parent is HBoxContainer:
			rect_global_position = menu_parent.get_child(h_id).rect_global_position + offset
		elif menu_parent is VBoxContainer:
			rect_global_position = menu_parent.get_child(v_id).rect_global_position + offset
		elif menu_parent is GridContainer:
			rect_global_position = menu_parent.get_child(g_id.x + g_id.y * menu_parent.columns).rect_global_position + offset
		
		if movable:
			if menu_parent is HBoxContainer:
				h_input()
			elif menu_parent is VBoxContainer:
				v_input()
			elif menu_parent is GridContainer:
				g_input()


func h_input():
	if Input.is_action_just_pressed("left"):
		h_id -= 1
		h_id = posmod(h_id, menu_parent.get_child_count())
	elif Input.is_action_just_pressed("right"):
		h_id += 1
		h_id = posmod(h_id, menu_parent.get_child_count())

func v_input():
	if Input.is_action_just_pressed("up"):
		v_id -= 1
		v_id = posmod(v_id, menu_parent.get_child_count())
	elif Input.is_action_just_pressed("down"):
		v_id += 1
		v_id = posmod(v_id, menu_parent.get_child_count())

func g_input():
	if Input.is_action_just_pressed("left"):
		g_id.x -= 1
		g_id.x = posmod(g_id.x, get_count_at_row(g_id.y))
	elif Input.is_action_just_pressed("right"):
		g_id.x += 1
		g_id.x = posmod(g_id.x, get_count_at_row(g_id.y))
	elif Input.is_action_just_pressed("up"):
		g_id.y -= 1
		g_id.y = posmod(g_id.y, get_count_at_column(g_id.x))
	elif Input.is_action_just_pressed("down"):
		g_id.y += 1
		g_id.y = posmod(g_id.y, get_count_at_column(g_id.x))


func get_count_at_column(column: int):
	var elements = menu_parent.get_child_count() / menu_parent.columns
	var remaining_elements = menu_parent.get_child_count() % menu_parent.columns
	
	if column < remaining_elements:
		return elements + 1
	return elements

func get_count_at_row(row: int):
	if row < menu_parent.get_child_count() / menu_parent.columns:
		return menu_parent.columns
	else:
		return menu_parent.get_child_count() % menu_parent.columns
