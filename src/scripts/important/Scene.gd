extends Node2D
class_name Scene

export(String, FILE, "*.wav") var music

func _ready():
	AudioManager.playMusic(music)
	GlobalCamera.target = $Actors/Player
