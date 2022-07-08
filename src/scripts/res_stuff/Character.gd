tool extends Resource
class_name Character

# Name, Level, and Experience
export var name: String
export(int, 1, 100) var lvl = 1
export(int, 0, 11400) var experience = 0

## Stats ##
# HP and MP #
export(int, 999) var hp
export(int, 1, 999) var maxhp
export(int, 999) var sp
export(int, 999) var maxsp

# Attack #
export(int, 1, 255) var regatk
var atk: int
var batatk: int

# Defense #
export(int, 1, 255) var regdef
var def: int
var batdef: int

# Speed #
export(int, 1, 255) var regspd
var spd: int
var batspd: int

# Statuses
export(Array, String) var statuses

# Inventory
export(Array, Resource) var inv

# Equipment
export(Dictionary) var equipment = {
	"right": null,
	"left": null,
	"head": null,
	"body": null,
	"legs": null,
	"accessory": null
}

export(Array, Resource) var equippable

export(Array, Resource) var spells_learned
export(Dictionary) var learnable_spells = {
	"Fire": 1
}

func clearBuffs():
	batatk = atk
	batdef = def
	batspd = spd

func clearStatuses():
	statuses = []

func die():
	clearStatuses()
	clearBuffs()
	statuses.append("unconscious")

func equippableItems(piece: String):
	var equippable_items = []
	for item in inv.size():
		match piece:
			"right", "left":
				if inv[item] is Weapon and inv[item] in equippable:
					equippable_items.append(item)
			"head":
				if inv[item] is Head and inv[item] in equippable:
					equippable_items.append(item)
			"body":
				if inv[item] is Body and inv[item] in equippable:
					equippable_items.append(item)
			"legs":
				if inv[item] is Legs and inv[item] in equippable:
					equippable_items.append(item)
			"accessory":
				if inv[item] is Accessory and inv[item] in equippable:
					equippable_items.append(item)
	return equippable_items

func learnAvailableSpells():
	spells_learned = []
	for spell in learnable_spells.keys():
		if lvl >= learnable_spells[spell]:
			spells_learned.append(load("res://src/resources/spells/%s.tres" % spell))

func get_exp_at_lvl(level: int):
	return round(pow(level, 2) + level * 14)
