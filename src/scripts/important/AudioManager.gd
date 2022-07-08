tool extends Node

onready var sounds = get_node("Sounds")
onready var music  = get_node("Music")

var snd_pause_pos: float
var mus_pause_pos: float

# Sound Stuff
func playSound(path: String):
	sounds.stream = load(path)
	sounds.play()

func pauseCurrSound():
	snd_pause_pos = sounds.get_playback_position()
	sounds.stop()

func resumeCurrSound():
	sounds.play(snd_pause_pos)

func stopAllSounds():
	sounds.stop()
	sounds.stream = null


# Music Stuff
func playMusic(path: String, loop: bool = true):
	music.stream = load(path)
	music.stream.set("edit/loop", loop)
	music.play()

func pauseCurrMusic():
	mus_pause_pos = music.get_playback_position()
	music.stop()

func resumeCurrMusic():
	music.play(mus_pause_pos)

func stopAllMusic():
	music.stop()
	music.stream = null
