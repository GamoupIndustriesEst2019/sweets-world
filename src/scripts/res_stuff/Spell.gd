tool extends Resource
class_name Spell

enum Scope {
	OneEnemy,
	AllEnemies,
	OneAlly,
	AllAllies
}

export(String) var name
export(String, MULTILINE) var description
export(int, 1, 999) var sp_cost = 1
export(int, 1, 999) var power = 1
export(int, 1, 100) var chance = 80

export(Scope) var scope = Scope.OneEnemy

export(Dictionary) var statuses = {
	"burn": 15
}
