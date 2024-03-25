extends Node2D

export var recharge_time = 2.0
export(PackedScene) var bullet_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	$ShootTimer.wait_time = recharge_time
	$ShootTimer.start()

func _on_ShootTimer_timeout():
	shoot()

func shoot():
	# look at each quarter of the screen, and shoot at the quarter with the most mobs in the area
	# the top left corner is (0, 0), bottom right is (750, 1280)
	var mobs = get_tree().get_nodes_in_group("mobs")
	if mobs.size() == 0:
		return
	var top_left = 0
	var top_right = 0
	var bottom_left = 0
	var bottom_right = 0
	for mob in mobs:
		var mob_pos = mob.get_global_position()
		if mob_pos.x < 375:
			if mob_pos.y < 640:
				top_left += 1
			else:
				bottom_left += 1
		else:
			if mob_pos.y < 640:
				top_right += 1
			else:
				bottom_right += 1
	var max_mobs = max(top_left, max(top_right, max(bottom_left, bottom_right)))
	if max_mobs == top_left:
		shoot_at(Vector2(188, 320))
	elif max_mobs == top_right:
		shoot_at(Vector2(463, 320))
	elif max_mobs == bottom_left:
		shoot_at(Vector2(188, 960))
	else:
		shoot_at(Vector2(463, 960))

func shoot_at(position):
	var bullet = bullet_scene.instance()
	bullet.set_target(position)
	bullet.look_at(position)
	get_tree().get_root().add_child(bullet)
