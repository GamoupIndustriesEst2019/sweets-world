extends Node2D

func _ready():
	$Tween.interpolate_property($ColorRect, "rect_position", $ColorRect.rect_position, Vector2($ColorRect.rect_position.x, 440), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
