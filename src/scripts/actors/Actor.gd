extends Node2D
class_name Actor

export var speed: int = 3

onready var ray: RayCast2D = $Body/Raycast
onready var coll: CollisionShape2D = $Body/Collision
onready var tween: Tween = $Body/Tween
onready var anim: AnimationPlayer = $Graphic/Anim

var anim_dir: String = "down"
var dirs = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}
var moving: bool
var movable: bool = true

func _process(_delta):
	moving = tween.is_active()
	if moving:
		anim.play("%s_w" % anim_dir)
	else:
		anim.play("%s_i" % anim_dir)

func move(dir: String, delta: float):
	anim_dir = dir
	ray.cast_to = dirs[dir] * 20 # 20 is the tile size
	ray.force_raycast_update()
	if !ray.is_colliding() or !ray.enabled:
		tween.interpolate_property(self, "position", position, position + ray.cast_to, 1.0/speed)
		tween.interpolate_property(coll, "position", ray.cast_to + Vector2(0, 4), Vector2(0, 4), 1.0/speed)
		tween.start()
		tween.seek(delta)
