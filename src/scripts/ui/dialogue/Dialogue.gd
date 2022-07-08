extends Control

signal d_done

enum {
	PANELTYPE_DEFAULT,
	PANELTYPE_DIM,
	PANELTYPE_TRANS
}

onready var dialogue = $DialogueLayer/DialoguePanel
onready var d_name   = dialogue.get_node("Name")
onready var d_text   = dialogue.get_node("Text")
onready var timer    = dialogue.get_node("Timer")
onready var ind      = dialogue.get_node("Indicator")
onready var ind_anim = dialogue.get_node("Indicator/Anim")

onready var ch_panel = dialogue.get_node("Choices")

var complete: bool = true
var choice
var choice_arr: Array

func _ready():
	dialogue.visible = false

func startDialogue(d_n, d_t: String, sound: bool = true, choices: Array = [], spd: float = 5, panel_type: int = PANELTYPE_DEFAULT, stops: Dictionary = {}, actions: Dictionary = {}) -> void:
	choice_arr = choices
	assert(choices.size() <= 4, "The argument \"choices\" is too big. Expected a size of at most 4, but the size is %s." % choices.size())
	
	# Panel Type
	match panel_type:
		PANELTYPE_DEFAULT:
			dialogue.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Default.tres"))
			ch_panel.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Default.tres"))
		PANELTYPE_DIM:
			dialogue.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Dim.tres"))
			ch_panel.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Dim.tres"))
		PANELTYPE_TRANS:
			dialogue.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Trans.tres"))
			ch_panel.set("custom_styles/panel", preload("res://assets/images/important/ui/res/Trans.tres"))
	
	if !choices.empty():
		for ch in ch_panel.get_node("ChoiceCont").get_children():
			ch_panel.get_node("ChoiceCont").remove_child(ch)
		for ch in choices:
			var label = Label.new()
			label.text = ch
			ch_panel.get_node("ChoiceCont").add_child(label)
	
	# Name Stuff
	if d_n in ["", null]:
		d_name.text = ""
	else:
		d_name.text = "%s" % d_n
	
	# Text Stuff
	d_text.bbcode_text = d_t
	if d_n in ["", null]:
		d_text.rect_position.y = 16
	else:
		d_text.rect_position.y = 40
	d_text.rect_position.x = 16
	
	dialogue.show()
	ind.hide()
	ch_panel.hide()
	complete = false
	ch_panel.get_node("Cursor").movable = false
	d_text.visible_characters = 0
	
	for c in d_text.text.length():
		if complete:
			d_text.visible_characters = -1
			break
		d_text.visible_characters += 1
		if d_text.visible_characters in actions.keys():
			for obj in actions[d_text.visible_characters]:
				for method in actions[d_text.visible_characters][obj].keys():
					obj.callv(method, actions[d_text.visible_characters][obj][method])
		if d_text.visible_characters in stops.keys():
			timer.start(stops[d_text.visible_characters])
			yield(timer, "timeout")
		if spd in range(1, 11):
			if sound:
				if d_n in ["", null]:
					playDialogueSound("Default")
				else:
					playDialogueSound(d_n)
			timer.start(0.1 / spd)
			yield(timer, "timeout")
	
	complete = true
	
	if choices.empty():
		ind.show()
		ind_anim.play("press z")
		yield(self, "d_done")
	else:
		var choice_len = choices
		choice_len.sort_custom(self, "sort_choices")
		choice_len = choice_len[0].length()
		
		ch_panel.rect_size.x = choice_len * 16 + 44
		ch_panel.rect_size.y = choices.size() * 16 + (ch_panel.get_node("ChoiceCont").get("custom_constants/separation") * (choices.size() - 1)) + 32
		
		ch_panel.rect_position.x = dialogue.rect_size.x - ch_panel.rect_size.x
		ch_panel.rect_position.y = -8 - ch_panel.rect_size.y
		
		ch_panel.show()
		ch_panel.get_node("Cursor").movable = true
		
		yield(self, "d_done")
	
	complete = false

func playDialogueSound(character: String) -> void:
	if character.ends_with(":"):
		character.erase(character.length() - 1, 1)
	AudioManager.playSound("res://assets/sounds/dialogue/%s.wav" % character)

func _input(event):
	if event.is_action_pressed("confirm"):
		if !complete:
			complete = true
		elif complete:
			if !choice_arr.empty():
				choice = choice_arr[ch_panel.get_node("Cursor").v_id]
			emit_signal("d_done")

func sort_choices(a, b):
	if a.length() > b.length():
		return true
