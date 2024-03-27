extends Node2D

export var recharge_time = 10.0
export(PackedScene) var bullet_scene

var last_shot_at = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	last_shot_at = OS.get_ticks_msec() - recharge_time * 1000

func shoot(position):
	if OS.get_ticks_msec() - last_shot_at < recharge_time * 1000:
		return
	var bullet = bullet_scene.instance()
	bullet.set_target(position)
	bullet.look_at(position)
	get_tree().get_root().add_child(bullet)
