extends Node2D

export var recharge_time = 5000.0
export(PackedScene) var bullet_scene

var has_shot = false

func _ready():
	pass

func shoot(position):
	if has_shot&&!$ResetTimer.is_stopped():
		return
	has_shot = true
	$ResetTimer.start()
	var bullet = bullet_scene.instance()
	bullet.set_target(position)
	bullet.look_at(position)
	get_node("/root/Main/Projectiles").add_child(bullet)
