extends Resource
class_name Item

enum Usable {
	None,
	Menu,
	Battle,
	Anytime
}

enum Scope {
	None,
	OneEnemy,
	AllEnemies,
	OneAlly,
	AllAllies
}

enum TargetType {
	Ally,
	Enemy
}

export(String) var name = ""
export(String) var what_it_does = ""
export(String, MULTILINE) var description = ""
export(int, 999999) var price = 0
export(Usable) var usable = Usable.None

export(String) var animation
export(String) var battle_animation
export(String, FILE, "*.wav") var sound

export(Scope) var scope = Scope.None
export(bool) var consume = false
export(Dictionary) var uses = {
	"healhp": 0,
	"healsp": 0
}

func use(target = null):
	match scope:
		Scope.OneAlly, Scope.OneEnemy:
			if !(target is int):
				assert(false, "Target must be an integer if the scope is either One Ally or One Enemy.")
			for use in uses.keys():
				call_deferred(use, target, uses[use])
		Scope.AllAllies:
			if target is int:
				assert(false, "Target must be null if the scope is either All Allies or All Enemies.")
			for pm in PlayerStuff.pms.size():
				for use in uses.keys():
					call_deferred(use, pm, uses[use])

func healhp(target: int, hp: int):
	match scope:
		Scope.OneAlly:
			PlayerStuff.pms[target].hp += hp
		Scope.OneEnemy:
			pass

func healsp(target: int, sp: int):
	match scope:
		Scope.OneAlly:
			PlayerStuff.pms[target].sp += sp
		Scope.OneEnemy:
			pass
