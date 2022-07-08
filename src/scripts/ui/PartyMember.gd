extends Control

onready var particlesdown = $ParticlesDown
onready var particlesup = $ParticlesUp
onready var anim = $Animation

func _ready():
	anim.play("off")

func attack_up():
	particlesup.texture = preload("res://assets/images/important/particles/attack_up.png")
	anim.play("on up")

func defense_up():
	particlesup.texture = preload("res://assets/images/important/particles/defense_up.png")
	anim.play("on up")

func heal():
	particlesdown.texture = preload("res://assets/images/important/particles/heal.png")
	anim.play("on down")
