extends Control

enum {
	MenuNone,
	MenuRegular,
	MenuPartyItem,
	MenuItems,
	MenuItemOpt,
	MenuItemUse,
	MenuItemGive,
	MenuItemSwap,
	MenuItemInfo,
	MenuItemToss,
	MenuPartySpell,
	MenuSpells,
	MenuSpellOpt,
	MenuSpellUse,
	MenuSpellSwap,
	MenuSpellInfo,
	MenuPartyEquip,
	MenuEquip,
	MenuChangeEquipment,
	MenuChooseEquipment,
	MenuUnequip,
	MenuPartyStats,
	MenuStats,
	MenuPartySwitch,
	MenuSwitch
	MenuSave
}

# Regular Menu Nodes
onready var regmenu = $MenuLayer/RegularMenu
onready var regcurs = $MenuLayer/RegularMenu/RegularPanel/OptPanel/Cursor

onready var pmcont = $MenuLayer/RegularMenu/RegularPanel/PartyMembers/PMCont
onready var pmcurs = $MenuLayer/RegularMenu/RegularPanel/PartyMembers/Cursor

# Item Menu Nodes
onready var itemmenu = $MenuLayer/ItemMenu
onready var itemcurs = $MenuLayer/ItemMenu/ItemPanel/Cursor
onready var itemcont = $MenuLayer/ItemMenu/ItemPanel/ItemCont

onready var itemoptmenu = $MenuLayer/ItemMenu/ItemPanel/Cursor/ItemOptPanel
onready var itemoptcurs = $MenuLayer/ItemMenu/ItemPanel/Cursor/ItemOptPanel/Cursor

onready var itemswapcurs = $MenuLayer/ItemMenu/ItemPanel/SwapCursor

# PM Choose Menu Nodes
onready var pmchoosemenu = $MenuLayer/ChooseMenu
onready var pmchoosecurs = $MenuLayer/ChooseMenu/ChoosePanel/PartyMembers/Cursor
onready var pmchoosecont = $MenuLayer/ChooseMenu/ChoosePanel/PartyMembers/PMCont

# Spell Menu Nodes
onready var spellmenu = $MenuLayer/SpellMenu
onready var spellcurs = $MenuLayer/SpellMenu/SpellPanel/Cursor
onready var spellcont = $MenuLayer/SpellMenu/SpellPanel/SpellCont

onready var spelloptmenu = $MenuLayer/SpellMenu/SpellPanel/Cursor/SpellOptPanel
onready var spelloptcurs = $MenuLayer/SpellMenu/SpellPanel/Cursor/SpellOptPanel/Cursor

onready var spellswapcurs = $MenuLayer/SpellMenu/SpellPanel/SwapCursor

# Equip Menu Nodes
onready var equipmenu = $MenuLayer/EquipMenu
onready var equipoptcurs = $MenuLayer/EquipMenu/EquipPanel/OptionPanel/Cursor
onready var equipmentcurs = $MenuLayer/EquipMenu/EquipPanel/EquipmentPanel/Cursor
onready var equippablemenu = $MenuLayer/EquipMenu/EquipPanel/EquippablePanel
onready var equippablecont = $MenuLayer/EquipMenu/EquipPanel/EquippablePanel/EquippableCont
onready var equippablecurs = $MenuLayer/EquipMenu/EquipPanel/EquippablePanel/Cursor

# Save Menu Nodes
onready var savemenu = $MenuLayer/SaveMenu
onready var savecurs = $MenuLayer/SaveMenu/SavePanel/Cursor
onready var savecont = $MenuLayer/SaveMenu/SavePanel/SaveFiles

# Other Nodes
onready var popuppanel = $MenuLayer/PopupPanel
onready var popuptimer = $MenuLayer/Timer
onready var infotimer = $MenuLayer/InfoTimer
onready var tosstimer = $MenuLayer/TossTimer
onready var choosetimer = $MenuLayer/ChooseTimer
onready var savetimer = $MenuLayer/SaveTimer

var curr_menu: int

var selected_pm: int
var selected_item: int
var selected_spell: int
var selected_equ: String

var item_used: bool = false

var f = File.new()
var dir = Directory.new()

func _ready():
	curr_menu = MenuNone
	PlayerStuff.connect("pms_updated", self, "_onPMsUpdated")
	popuppanel.hide()

func _process(_delta):
	PlayerStuff.emit_signal("pms_updated")
	
	# \ - Visibilities - / #
	### Regular Menu ###
	regmenu.visible = curr_menu in [MenuRegular, MenuPartyItem, MenuPartySpell, MenuPartyEquip, MenuPartyStats, MenuPartySwitch]
	
	# Regular Menu Cursor #
	regcurs.visible = regmenu.visible
	regcurs.movable = curr_menu == MenuRegular
	
	# Party Cursor #
	pmcurs.visible = curr_menu in [MenuPartyItem, MenuPartySpell, MenuPartyEquip, MenuPartyStats, MenuPartySwitch]
	pmcurs.movable = pmcurs.visible
	
	
	### Item Menu ###
	itemmenu.visible = curr_menu in [MenuItems, MenuItemOpt, MenuItemSwap, MenuItemInfo, MenuItemToss]
	
	# Item Menu Cursor #
	itemcurs.visible = itemmenu.visible
	itemcurs.movable = curr_menu in [MenuItems, MenuItemSwap]
	
	# Item Option Menu #
	itemoptmenu.visible = curr_menu in [MenuItemOpt, MenuItemInfo, MenuItemToss]
	
	# Item Option Cursor #
	itemoptcurs.visible = itemoptmenu.visible
	itemoptcurs.movable = curr_menu == MenuItemOpt
	
	# Item Swap Cursor #
	itemswapcurs.visible = curr_menu == MenuItemSwap
	
	# PM Choose Menu #
	pmchoosemenu.visible = curr_menu in [MenuItemUse, MenuItemGive]
	
	# PM Choose Cursor #
	pmchoosecurs.visible = pmchoosemenu.visible
	pmchoosecurs.movable = (curr_menu == MenuItemUse and PlayerStuff.pms[selected_pm].inv[selected_item].scope == Item.Scope.OneAlly and !item_used) or (curr_menu == MenuItemGive)
	
	### Spell Menu ###
	spellmenu.visible = curr_menu in [MenuSpells, MenuSpellOpt, MenuSpellSwap, MenuSpellInfo]
	
	# Spell Cursor #
	spellcurs.visible = spellmenu.visible
	spellcurs.movable = curr_menu in [MenuSpells, MenuSpellSwap]
	
	# Spell Option Menu #
	spelloptmenu.visible = curr_menu in [MenuSpellOpt, MenuSpellInfo]
	
	# Spell Option Cursor #
	spelloptcurs.visible = spelloptmenu.visible
	spelloptcurs.movable = curr_menu == MenuSpellOpt
	
	# Spell Swap Cursor #
	spellswapcurs.visible = curr_menu == MenuSpellSwap
	
	### Equip Menu ###
	equipmenu.visible = curr_menu in [MenuEquip, MenuChangeEquipment, MenuChooseEquipment, MenuUnequip]
	equippablecont.visible = curr_menu == MenuChooseEquipment
	equipmenu.get_node("EquipPanel/OptionPanel").visible = curr_menu == MenuEquip
	
	# Equip Menu Cursor
	equipoptcurs.visible = equipmenu.get_node("EquipPanel/EquipmentPanel").visible
	equipoptcurs.movable = equipmenu.get_node("EquipPanel/OptionPanel").visible
	
	equipmentcurs.visible = curr_menu in [MenuChangeEquipment, MenuChooseEquipment, MenuUnequip]
	equipmentcurs.movable = curr_menu in [MenuChangeEquipment, MenuUnequip]
	
	equippablemenu.visible = curr_menu == MenuChooseEquipment
	equippablecurs.visible = equippablemenu.visible
	equippablecurs.movable = equippablecurs.visible
	
	### Save Menu ###
	savemenu.visible = curr_menu == MenuSave
	
	# Save Menu Cursor
	savecurs.visible = savemenu.visible
	savecurs.movable = curr_menu == MenuSave and !Dialogue.dialogue.visible
	# \ - End of Visibilities - / #
	
	if Input.is_action_just_pressed("confirm") and tosstimer.time_left == 0 and infotimer.time_left == 0 and choosetimer.time_left == 0 and savetimer.time_left == 0 and !Dialogue.dialogue.visible and !item_used:
		match curr_menu:
			MenuRegular:
				match regcurs.v_id:
					0:
						if !all_pms_have_no_items():
							curr_menu = MenuPartyItem
						else:
							AudioManager.playSound(SoundPaths.Wrong)
							popup("You don't have any items.", 0.5)
					1:
						if !all_pms_have_no_spells():
							curr_menu = MenuPartySpell
						else:
							AudioManager.playSound(SoundPaths.Wrong)
							popup("You don't have any spells.", 0.5)
					2:
						curr_menu = MenuPartyEquip
					3:
						curr_menu = MenuPartyStats
					4:
						curr_menu = MenuPartySwitch
					5:
						curr_menu = MenuSave
					6:
						close()
			MenuPartyItem:
				if PlayerStuff.pms[pmcurs.v_id].inv.size() < 1:
					AudioManager.playSound(SoundPaths.Wrong)
					popup("%s has no items." % PlayerStuff.pms[pmcurs.v_id].name, 1)
				else:
					selected_pm = pmcurs.v_id
					itemcurs.g_id = Vector2.ZERO
					curr_menu = MenuItems
			MenuItems:
				selected_item = itemcurs.g_id.x + itemcurs.g_id.y * itemcont.columns
				itemoptcurs.v_id = 0
				curr_menu = MenuItemOpt
			MenuItemOpt:
				match itemoptcurs.v_id:
					0: # Use
						if PlayerStuff.pms[selected_pm].inv[selected_item].usable in [Item.Usable.None, Item.Usable.Battle]:
							AudioManager.playSound(SoundPaths.Wrong)
							popup("%s can't use the %s." % [PlayerStuff.pms[selected_pm].name, PlayerStuff.pms[selected_pm].inv[selected_item].name], 0.5)
						else:
							pmchoosecurs.v_id = selected_pm
							curr_menu = MenuItemUse
							pmchoosemenu.get_node("ChoosePanel/WhoPanel/WhoText").text = "Use on who?"
					1: # Give
						pmchoosecurs.v_id = selected_pm
						curr_menu = MenuItemGive
						pmchoosemenu.get_node("ChoosePanel/WhoPanel/WhoText").text = "Give to who?"
					2: # Swap
						curr_menu = MenuItemSwap
						itemswapcurs.rect_global_position = itemcurs.rect_global_position
					3: # Info
						if infotimer.time_left == 0:
							curr_menu = MenuItemInfo
							Dialogue.startDialogue("%s - %s" % [PlayerStuff.pms[selected_pm].inv[selected_item].name, PlayerStuff.pms[selected_pm].inv[selected_item].what_it_does], PlayerStuff.pms[selected_pm].inv[selected_item].description, false, [], 0)
							yield(Dialogue, "d_done")
							Dialogue.dialogue.hide()
							itemoptcurs.v_id = 0
							curr_menu = MenuItemOpt
							infotimer.start(0.01)
					4: # Toss
						curr_menu = MenuItemToss
						Dialogue.startDialogue("", "Do you want to toss the %s?" % PlayerStuff.pms[selected_pm].inv[selected_item].name, false, ["Yes", "No"])
						yield(Dialogue, "d_done")
						if Dialogue.choice == "Yes":
							itemcurs.g_id = Vector2.ZERO
							var last_item_name = PlayerStuff.pms[selected_pm].inv[selected_item].name
							PlayerStuff.pms[selected_pm].inv.remove(selected_item)
							Dialogue.startDialogue("", "Tossed the %s." % last_item_name, false)
							yield(Dialogue, "d_done")
							if pm_has_items(selected_pm):
								curr_menu = MenuItems
							elif !pm_has_items(selected_pm):
								if all_pms_have_no_items():
									curr_menu = MenuRegular
								else:
									curr_menu = MenuPartyItem
							Dialogue.dialogue.hide()
						else:
							Dialogue.dialogue.hide()
							itemoptcurs.v_id = 0
							curr_menu = MenuItemOpt
						tosstimer.start(0.01)
			MenuItemUse:
				item_used = true
				AudioManager.playSound(PlayerStuff.pms[selected_pm].inv[selected_item].sound)
				match PlayerStuff.pms[selected_pm].inv[selected_item].scope:
					Item.Scope.OneAlly:
						pmchoosecont.get_child(pmchoosecurs.v_id).call_deferred(PlayerStuff.pms[selected_pm].inv[selected_item].animation)
						PlayerStuff.pms[selected_pm].inv[selected_item].use(pmchoosecurs.v_id)
						yield(pmchoosecont.get_child(pmchoosecurs.v_id).get_node("Animation"), "animation_finished")
					Item.Scope.AllAllies:
						for pm in PlayerStuff.pms.size():
							pmchoosecont.get_child(pm).call_deferred(PlayerStuff.pms[selected_pm].inv[selected_item].animation)
						PlayerStuff.pms[selected_pm].inv[selected_item].use()
						yield(pmchoosecont.get_child(PlayerStuff.pms.size() - 1).get_node("Animation"), "animation_finished")
				PlayerStuff.pms[selected_pm].inv.remove(selected_item)
				item_used = false
				if pm_has_items(selected_pm):
					itemcurs.g_id = Vector2.ZERO
					curr_menu = MenuItems
				elif !pm_has_items(selected_pm):
					if all_pms_have_no_items():
						curr_menu = MenuRegular
					else:
						curr_menu = MenuPartyItem
			MenuItemGive:
				if pmchoosecurs.v_id == selected_pm:
					AudioManager.playSound(SoundPaths.Wrong)
					popup("%s can't give the %s to themselves." % [PlayerStuff.pms[selected_pm].name, PlayerStuff.pms[selected_pm].inv[selected_item].name], 0.5)
				else:
					var last_item_name = PlayerStuff.pms[selected_pm].inv[selected_item].name
					PlayerStuff.pms[pmchoosecurs.v_id].inv.append(PlayerStuff.pms[selected_pm].inv[selected_item])
					PlayerStuff.pms[selected_pm].inv.remove(selected_item)
					Dialogue.startDialogue("", "Gave the %s to %s." % [last_item_name, PlayerStuff.pms[pmchoosecurs.v_id].name], false)
					yield(Dialogue, "d_done")
					Dialogue.dialogue.hide()
					if pm_has_items(selected_pm):
						itemcurs.g_id = Vector2.ZERO
						curr_menu = MenuItems
					else:
						curr_menu = MenuPartyItem
					choosetimer.start(0.01)
			MenuItemSwap:
				var temp = PlayerStuff.pms[selected_pm].inv[itemcurs.g_id.x + itemcurs.g_id.y * itemcont.columns]
				PlayerStuff.pms[selected_pm].inv[itemcurs.g_id.x + itemcurs.g_id.y * itemcont.columns] = PlayerStuff.pms[selected_pm].inv[selected_item]
				PlayerStuff.pms[selected_pm].inv[selected_item] = temp
				
				curr_menu = MenuItems
			MenuPartySpell:
				if PlayerStuff.pms[pmcurs.v_id].spells_learned.size() < 1:
					AudioManager.playSound(SoundPaths.Wrong)
					popup("%s has no spells." % PlayerStuff.pms[pmcurs.v_id].name, 1)
				else:
					selected_pm = pmcurs.v_id
					spellcurs.g_id = Vector2.ZERO
					curr_menu = MenuSpells
			MenuSpells:
				selected_spell = spellcurs.g_id.x + spellcurs.g_id.y * spellcurs.menu_parent.columns
				spelloptcurs.v_id = 0
				curr_menu = MenuSpellOpt
			MenuSpellOpt:
				match spelloptcurs.v_id:
					0: # Use
						if PlayerStuff.pms[selected_pm].sp < PlayerStuff.pms[selected_pm].spells_learned[selected_spell].sp_cost:
							AudioManager.playSound(SoundPaths.Wrong)
							popup("%s doesn't have enough SP for this spell." % PlayerStuff.pms[selected_pm].name, 0.5)
						elif PlayerStuff.pms[selected_pm].spells_learned[selected_spell].scope in [Spell.Scope.OneEnemy, Spell.Scope.AllEnemies]:
							AudioManager.playSound(SoundPaths.Wrong)
							popup("%s can't use this spell here." % PlayerStuff.pms[selected_pm].name, 0.5)
						else:
							pmchoosecurs.v_id = selected_pm
							curr_menu = MenuSpellUse
							pmchoosemenu.get_node("ChoosePanel/WhoPanel/WhoText").text = "Use on who?"
					1: # Swap
						curr_menu = MenuSpellSwap
						spellswapcurs.rect_global_position = spellcurs.rect_global_position
					2: # Info
						if infotimer.time_left == 0:
							curr_menu = MenuSpellInfo
							Dialogue.startDialogue("- %s -" % PlayerStuff.pms[selected_pm].spells_learned[selected_spell].name, PlayerStuff.pms[selected_pm].spells_learned[selected_spell].description, false, [], 0)
							yield(Dialogue, "d_done")
							Dialogue.dialogue.hide()
							itemoptcurs.v_id = 0
							curr_menu = MenuSpellOpt
							infotimer.start(0.01)
			MenuSpellSwap:
				var temp = PlayerStuff.pms[selected_pm].spells_learned[spellcurs.g_id.x + spellcurs.g_id.y * spellcont.columns]
				PlayerStuff.pms[selected_pm].spells_learned[spellcurs.g_id.x + spellcurs.g_id.y * spellcont.columns] = PlayerStuff.pms[selected_pm].spells_learned[selected_spell]
				PlayerStuff.pms[selected_pm].spells_learned[selected_spell] = temp
				
				curr_menu = MenuSpells
			MenuPartyEquip:
				selected_pm = pmcurs.v_id
				equipoptcurs.h_id = 0
				curr_menu = MenuEquip
			MenuEquip:
				match equipoptcurs.h_id:
					0:
						curr_menu = MenuChangeEquipment
					1:
						optimizeEquipment(selected_pm)
					2:
						curr_menu = MenuUnequip
			MenuChangeEquipment:
				selected_equ = equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()
				if PlayerStuff.pms[selected_pm].equippableItems(selected_equ).size() >= 1:
					curr_menu = MenuChooseEquipment
				else:
					AudioManager.playSound(SoundPaths.Wrong)
					popup("%s has no equipment of that type." % PlayerStuff.pms[selected_pm].name, 0.5)
			MenuChooseEquipment:
				equipPiece(selected_equ, PlayerStuff.pms[selected_pm].inv[PlayerStuff.pms[selected_pm].equippableItems(selected_equ)[equippablecurs.g_id.x + equippablecurs.g_id.y * equippablecurs.menu_parent.columns]])
				
				curr_menu = MenuChangeEquipment
			MenuUnequip:
				if equipmentcurs.v_id != 1:
					if PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()] != null:
						PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()])
						PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()] = null
					else:
						AudioManager.playSound(SoundPaths.Wrong)
						popup("There is no equipment there.", 0.5)
				else:
					if PlayerStuff.pms[selected_pm].equipment.right != null:
						if PlayerStuff.pms[selected_pm].equipment.right.two_handed:
							PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment.right)
							PlayerStuff.pms[selected_pm].equipment.right = null
						else:
							PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()])
							PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()] = null
					else:
						PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()])
						PlayerStuff.pms[selected_pm].equipment[equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_child(equipmentcurs.v_id).name.to_lower()] = null
			MenuSave:
				if dir.file_exists("user://save%s.sws" % savecurs.v_id):
					Dialogue.startDialogue("", "Are you sure you want to overwrite this save file?", false, ["Yes", "No"])
					yield(Dialogue, "d_done")
					Dialogue.dialogue.hide()
					savetimer.start(0.01)
					if Dialogue.choice == "No":
						curr_menu = MenuSave
					else:
						ImportantStuff.saveGame(savecurs.v_id)
						curr_menu = MenuRegular
				else:
					ImportantStuff.saveGame(savecurs.v_id)
					curr_menu = MenuRegular
	
	if Input.is_action_just_pressed("cancel") and tosstimer.time_left == 0 and infotimer.time_left == 0 and choosetimer.time_left == 0 and savetimer.time_left == 0 and !Dialogue.dialogue.visible and !item_used:
		match curr_menu:
			MenuRegular:
				close()
			MenuPartyItem, MenuPartySpell, MenuPartyEquip, MenuPartyStats, MenuPartySwitch, MenuSave:
				curr_menu = MenuRegular
			MenuItems:
				curr_menu = MenuPartyItem
			MenuItemOpt:
				curr_menu = MenuItems
			MenuItemUse, MenuItemGive:
				itemoptcurs.v_id = 0
				curr_menu = MenuItemOpt
			MenuItemInfo, MenuItemToss:
				if Dialogue.complete:
					Dialogue.emit_signal("d_done")
					Dialogue.dialogue.hide()
					itemoptcurs.v_id = 0
					curr_menu = MenuItemOpt
			MenuSpells:
				curr_menu = MenuPartySpell
			MenuSpellOpt:
				curr_menu = MenuSpells
			MenuEquip:
				curr_menu = MenuPartyEquip
			MenuChangeEquipment, MenuUnequip:
				curr_menu = MenuEquip
			MenuChooseEquipment:
				curr_menu = MenuChangeEquipment
	
	### Regular Menu Variable Stuff
	$MenuLayer/RegularMenu/RegularPanel/OtherPanel/Ora/Value.text = str(PlayerStuff.currency)
	$MenuLayer/RegularMenu/RegularPanel/OtherPanel/Steps/Value.text = str(PlayerStuff.steps)
	
	for key in ImportantStuff.keys.size():
		var key_type: String = "no"
		if ImportantStuff.keys[key]:
			match key:
				0:
					key_type = "water"
				1:
					key_type = "fire"
				2:
					key_type = "earth"
				3:
					key_type = "air"
		else:
			key_type = "no"
		$MenuLayer/RegularMenu/RegularPanel/OtherPanel/Keys/KeyCont.get_child(key).texture = load("res://assets/images/keys/%s_key.png" % key_type)
	
	### Party Member Stuff
	for pm in pmcont.get_child_count():
		match curr_menu:
			MenuRegular:
				pmcont.get_child(pm).get_node("Name").self_modulate = Color8(255, 255, 255)
			MenuPartyItem:
				if PlayerStuff.pms[pm].inv.size() < 1:
					pmcont.get_child(pm).get_node("Name").self_modulate = Color8(152, 152, 152)
				else:
					pmcont.get_child(pm).get_node("Name").self_modulate = Color8(255, 255, 255)
			MenuPartySpell:
				if PlayerStuff.pms[pm].spells_learned.size() < 1:
					pmcont.get_child(pm).get_node("Name").self_modulate = Color8(152, 152, 152)
				else:
					pmcont.get_child(pm).get_node("Name").self_modulate = Color8(255, 255, 255)
	
	### Item Menu Stuff
	itemmenu.get_node("ItemPanel/NamePanel/Name").text = "%s's Items" % PlayerStuff.pms[selected_pm].name
	
	if curr_menu == MenuItemUse:
		if PlayerStuff.pms[selected_pm].inv[selected_item].scope == Item.Scope.AllAllies:
			pmchoosecurs.v_id += 1
			if pmchoosecurs.v_id >= PlayerStuff.pms.size():
				pmchoosecurs.v_id = 0
	
	### Spell Menu Stuff
	spellmenu.get_node("SpellPanel/NamePanel/Name").text = "%s's Spells" % PlayerStuff.pms[selected_pm].name
	spellmenu.get_node("SpellPanel/SpellPointsPanel/SP/Value").text = str(PlayerStuff.pms[selected_pm].sp)
	spellmenu.get_node("SpellPanel/SpellPointsPanel/SP/Max").text = str(PlayerStuff.pms[selected_pm].maxsp)
	
	for spell in PlayerStuff.pms[selected_pm].spells_learned.size():
		if spellmenu.visible:
			if PlayerStuff.pms[selected_pm].sp < PlayerStuff.pms[selected_pm].spells_learned[spell].sp_cost or PlayerStuff.pms[selected_pm].spells_learned[selected_spell].scope in [Spell.Scope.OneEnemy, Spell.Scope.AllEnemies]:
				spellcont.get_child(spell).self_modulate = Color8(152, 152, 152)
			else:
				spellcont.get_child(spell).self_modulate = Color8(255, 255, 255)
	
	for spell in PlayerStuff.pms[selected_pm].spells_learned.size():
		if spellmenu.visible:
			spellcont.get_child(spell).text = PlayerStuff.pms[selected_pm].spells_learned[spell].name
			spellcont.get_child(spell).get_node("SP").text = str(PlayerStuff.pms[selected_pm].spells_learned[spell].sp_cost)
	
	### Equip Menu Stuff
	equipmenu.get_node("EquipPanel/NamePanel/Name").text = "%s's Equipment" % PlayerStuff.pms[selected_pm].name
	
	equipmenu.get_node("EquipPanel/CharacterStuff/ATK/Val").text = str(PlayerStuff.pms[selected_pm].atk)
	equipmenu.get_node("EquipPanel/CharacterStuff/DEF/Val").text = str(PlayerStuff.pms[selected_pm].def)
	equipmenu.get_node("EquipPanel/CharacterStuff/SPD/Val").text = str(PlayerStuff.pms[selected_pm].spd)
	
	if equipmenu.visible:
		for piece in equipmenu.get_node("EquipPanel/EquipmentPanel/EquipmentCont").get_children():
			if piece.name == "Right":
				if PlayerStuff.pms[selected_pm].equipment.left == null:
					if PlayerStuff.pms[selected_pm].equipment.right == null:
						piece.get_node("Piece").text = "Hands"
					else:
						piece.get_node("Piece").text = PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()].name
				else:
					if PlayerStuff.pms[selected_pm].equipment.right == null:
						piece.get_node("Piece").text = ""
					else:
						piece.get_node("Piece").text = PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()].name
			
			elif piece.name == "Left":
				if PlayerStuff.pms[selected_pm].equipment["right"] != null and PlayerStuff.pms[selected_pm].equipment["right"].two_handed:
					piece.get_node("Piece").text = "/2-Handed"
				elif PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()] != null:
					piece.get_node("Piece").text = PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()].name
				else:
					piece.get_node("Piece").text = ""
			
			else:
				piece.get_node("Piece").text = "" if PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()] == null else PlayerStuff.pms[selected_pm].equipment[piece.name.to_lower()].name
		
	### Save Menu Stuff
	for save in savecont.get_child_count():
		if dir.file_exists("user://save%s.sws" % save):
			f.open("user://save%s.sws" % save, File.READ)
			var file_data = parse_json(f.get_as_text())
			savecont.get_child(save).get_node("SaveName").text = "Save File %s" % (save + 1)
			savecont.get_child(save).get_node("PM1Name").text = file_data.pms["pm1"].name
			savecont.get_child(save).get_node("Currency").text = "Ora: %s" % file_data.currency
			savecont.get_child(save).get_node("Steps").text = "Steps: %s" % file_data.steps
			savecont.get_child(save).get_node("Scene").text = "Scene: %s" % file_data.scene_name
			var keys = 0
			for key in ImportantStuff.keys:
				if key:
					keys += 1
			savecont.get_child(save).get_node("Keys").text = "Keys: %s" % keys
		else:
			savecont.get_child(save).get_node("SaveName").text = "Empty File %s" % (save + 1)
			savecont.get_child(save).get_node("PM1Name").text = ""
			savecont.get_child(save).get_node("Currency").text = ""
			savecont.get_child(save).get_node("Steps").text = ""
			savecont.get_child(save).get_node("Scene").text = ""
			savecont.get_child(save).get_node("Keys").text = ""

func open():
	curr_menu = MenuRegular
	get_node("..").movable = false

func close():
	curr_menu = MenuNone
	popuppanel.visible = false
	get_node("..").movable = true

func _onPMsUpdated():
	for pm in PlayerStuff.pms.size():
		if pmcont.get_child_count() < pm + 1:
			var new_pm = preload("res://scenes/subscenes/ui/menus/world/PartyMember.tscn").instance()
			pmcont.add_child(new_pm)
		if pmchoosecont.get_child_count() < pm + 1:
			var new_pm = preload("res://scenes/subscenes/ui/menus/world/PartyMember.tscn").instance()
			pmchoosecont.add_child(new_pm)
	
	for extra in range(PlayerStuff.pms.size(), pmcont.get_child_count()):
		pmcont.get_child(extra).queue_free()
	
	for extra in range(PlayerStuff.pms.size(), pmchoosecont.get_child_count()):
		pmchoosecont.get_child(extra).queue_free()
	
	for pm in PlayerStuff.pms.size():
		pmcont.get_child(pm).get_node("Name").text = PlayerStuff.pms[pm].name
		pmcont.get_child(pm).get_node("Level/Val").text = str(PlayerStuff.pms[pm].lvl)
		pmcont.get_child(pm).get_node("HP/Cur").text = str(PlayerStuff.pms[pm].hp)
		pmcont.get_child(pm).get_node("HP/Max").text = str(PlayerStuff.pms[pm].maxhp)
		pmcont.get_child(pm).get_node("SP/Cur").text = str(PlayerStuff.pms[pm].sp)
		pmcont.get_child(pm).get_node("SP/Max").text = str(PlayerStuff.pms[pm].maxsp)
		pmchoosecont.get_child(pm).get_node("Name").text = PlayerStuff.pms[pm].name
		pmchoosecont.get_child(pm).get_node("Level/Val").text = str(PlayerStuff.pms[pm].lvl)
		pmchoosecont.get_child(pm).get_node("HP/Cur").text = str(PlayerStuff.pms[pm].hp)
		pmchoosecont.get_child(pm).get_node("HP/Max").text = str(PlayerStuff.pms[pm].maxhp)
		pmchoosecont.get_child(pm).get_node("SP/Cur").text = str(PlayerStuff.pms[pm].sp)
		pmchoosecont.get_child(pm).get_node("SP/Max").text = str(PlayerStuff.pms[pm].maxsp)
	
	# Items #
	for item in PlayerStuff.pms[selected_pm].inv.size():
		if itemcont.get_child_count() < item + 1:
			var new_item = Label.new()
			new_item.rect_min_size.x = 16 * 12
			new_item.rect_min_size.y = 16
			itemcont.add_child(new_item)
	
	for extra in range(PlayerStuff.pms[selected_pm].inv.size(), itemcont.get_child_count()):
		itemcont.get_child(extra).queue_free()
	
	for item in PlayerStuff.pms[selected_pm].inv.size():
		itemcont.get_child(item).text = PlayerStuff.pms[selected_pm].inv[item].name
	
	# Spells #
	for spell in PlayerStuff.pms[selected_pm].spells_learned.size():
		if spellcont.get_child_count() < spell + 1:
			var new_spell = Label.new()
			new_spell.rect_min_size.x = 160
			new_spell.rect_min_size.y = 16
			spellcont.add_child(new_spell)
			
			# SP
			var sp_cost = Label.new()
			sp_cost.name = "SP"
			sp_cost.rect_position.x = 176
			sp_cost.rect_position.y = 0
			sp_cost.rect_min_size.x = 48
			sp_cost.rect_min_size.y = 16
			sp_cost.align = Label.ALIGN_RIGHT
			new_spell.add_child(sp_cost)
	
	for extra in range(PlayerStuff.pms[selected_pm].spells_learned.size(), spellcont.get_child_count()):
		spellcont.get_child(extra).queue_free()
	
	# Equipment #
	for equippable in PlayerStuff.pms[selected_pm].equippableItems(selected_equ).size():
		if equippablecont.get_child_count() < equippable + 1:
			var new_equ = Label.new()
			new_equ.rect_min_size.x = 16 * 12
			new_equ.rect_min_size.y = 16
			equippablecont.add_child(new_equ)
	
	for extra in range(PlayerStuff.pms[selected_pm].equippableItems(selected_equ).size(), equippablecont.get_child_count()):
		equippablecont.get_child(extra).queue_free()
	
	for equippable in PlayerStuff.pms[selected_pm].equippableItems(selected_equ).size():
		equippablecont.get_child(equippable).text = PlayerStuff.pms[selected_pm].inv[PlayerStuff.pms[selected_pm].equippableItems(selected_equ)[equippable]].name

func popup(text: String, time: float) -> void:
	popuppanel.get_node("Text").text = text
	popuppanel.show()
	popuptimer.start(0.5)
	yield(popuptimer, "timeout")
	popuppanel.hide()

func pm_has_items(pm: int):
	return PlayerStuff.pms[pm].inv.size() > 0

func all_pms_have_no_items():
	var thing = []
	for pm in PlayerStuff.pms.size():
		thing.append(!pm_has_items(pm))
	
	for i in thing:
		if !i:
			return false
	return true

func sort_hands(a, b):
	if PlayerStuff.pms[selected_pm].inv[a].atk > PlayerStuff.pms[selected_pm].inv[b].atk:
		return true

func sort_armor(a, b):
	if PlayerStuff.pms[selected_pm].inv[a].def > PlayerStuff.pms[selected_pm].inv[b].def:
		return true

func optimizeEquipment(pm: int):
	unequipAll(pm)
	for piece in ["right", "left", "head", "body", "legs", "accessory"]:
		if (piece == "left" and PlayerStuff.pms[pm].equipment["right"] != null and PlayerStuff.pms[pm].equipment["right"].two_handed):
			continue
		else:
			var best_piece = []
			for item in PlayerStuff.pms[pm].inv.size():
				if (piece in ["right", "left"] and ImportantStuff.var_type_in_array(PlayerStuff.pms[pm].inv[item], [Weapon])) or (piece in ["head", "body", "legs", "accessory"] and ImportantStuff.var_type_in_array(PlayerStuff.pms[pm].inv[item], [Head, Body, Legs, Accessory])):
					best_piece.append(item)
			
			match piece:
				"right", "left":
					best_piece.sort_custom(self, "sort_hands")
				_:
					best_piece.sort_custom(self, "sort_armor")
			
			if best_piece.size() >= 1:
				PlayerStuff.pms[pm].equipment[piece] = PlayerStuff.pms[pm].inv[best_piece[0]]
				PlayerStuff.pms[pm].inv.remove(best_piece[0])

func unequipAll(pm: int):
	for piece in PlayerStuff.pms[pm].equipment.keys():
		if PlayerStuff.pms[pm].equipment[piece] != null:
			PlayerStuff.pms[pm].inv.append(PlayerStuff.pms[pm].equipment[piece])
			PlayerStuff.pms[pm].equipment[piece] = null

func equipPiece(piece: String, item):
	if PlayerStuff.pms[selected_pm].equipment[piece] != null:
		PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment[piece])
	PlayerStuff.pms[selected_pm].equipment[piece] = item
	PlayerStuff.pms[selected_pm].inv.remove(PlayerStuff.pms[selected_pm].equippableItems(selected_equ)[equippablecurs.g_id.x + equippablecurs.g_id.y * equippablecurs.menu_parent.columns])
	
	match piece:
		"right":
			if PlayerStuff.pms[selected_pm].equipment[piece].two_handed:
				PlayerStuff.pms[selected_pm].equipment.left = null
		"left":
			if PlayerStuff.pms[selected_pm].equipment.right != null:
				if PlayerStuff.pms[selected_pm].equipment.right.two_handed:
					PlayerStuff.pms[selected_pm].inv.append(PlayerStuff.pms[selected_pm].equipment.right)
					PlayerStuff.pms[selected_pm].equipment.right = null
			if PlayerStuff.pms[selected_pm].equipment[piece].two_handed:
				PlayerStuff.pms[selected_pm].equipment.right = PlayerStuff.pms[selected_pm].equipment[piece]
				PlayerStuff.pms[selected_pm].equipment[piece] = null

func pm_has_spells(pm: int):
	return PlayerStuff.pms[pm].spells_learned.size() > 0

func all_pms_have_no_spells():
	var thing = []
	for pm in PlayerStuff.pms.size():
		thing.append(!pm_has_spells(pm))
	
	for i in thing:
		if !i:
			return false
	return true
