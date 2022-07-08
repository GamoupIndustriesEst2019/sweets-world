extends Node

signal pms_updated

var totalChars = {
	"Test": preload("res://src/resources/characters/Test.tres"),
	"Test2": preload("res://src/resources/characters/Test2.tres"),
	"Platty": preload("res://src/resources/characters/Platty.tres")
}

var currency: int = 200
var steps: int = 0

var pms: Array = [
	totalChars.Test,
	totalChars.Test2,
	totalChars.Platty
]

func _ready():
	for character in totalChars.keys():
		totalChars[character].learnAvailableSpells()

func _process(_delta):
	currency = clamp(currency, 0, 999999)
	steps = clamp(steps, 0, 99999)
	
	for pm in pms:
		pm.hp = clamp(pm.hp, 0, pm.maxhp)
		pm.sp = clamp(pm.sp, 0, pm.maxsp)
	
	for pm in pms:
		var eqatk = 0
		var eqdef = 0
		var eqspd = 0
		for equipment in pm.equipment.keys():
			if pm.equipment[equipment] != null:
				eqdef += pm.equipment[equipment].def
				if ImportantStuff.var_type_in_array(pm.equipment[equipment], [Weapon]):
					eqatk += pm.equipment[equipment].atk
				elif ImportantStuff.var_type_in_array(pm.equipment[equipment], [Head, Body, Legs, Accessory]):
					eqspd += pm.equipment[equipment].spd
		pm.atk = pm.regatk + eqatk
		pm.def = pm.regdef + eqdef
		pm.spd = pm.regspd + eqspd

func inflictStatuses():
	for pm in pms:
		if pm.statuses.has("poison"):
			pm.hp -= 1

func no_statuses():
	for pm in pms:
		if !pm.statuses.empty():
			return false
	return true
