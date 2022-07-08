extends Node2D

signal fade_out_done
signal fade_in_done

onready var screen_fade = $ScreenLayer/ScreenFade
onready var tween = $Tween

func fadeOut(to: Color, time: float):
	screen_fade.color.r = to.r
	screen_fade.color.g = to.g
	screen_fade.color.b = to.b
	tween.interpolate_property(screen_fade, "color:a", 0, to.a, time)
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("fade_out_done")

func fadeIn(from: Color, time: float):
	screen_fade.color.r = from.r
	screen_fade.color.g = from.g
	screen_fade.color.b = from.b
	tween.interpolate_property(screen_fade, "color:a", from.a, 0, time)
	tween.start()
	emit_signal("fade_in_done")
