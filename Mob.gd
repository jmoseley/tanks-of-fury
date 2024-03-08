extends Area2D

export var health = 100
export var turn_rotation_speed = 3
export var speed = 0

signal hit(damage)
signal die(age)

var angle = 0
var rng = RandomNumberGenerator.new()

var time_since_position_change = INF
var target_position = Vector2.ZERO
var am_firing = true
var age = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("mobs")
	var mob_types = $Body.frames.get_animation_names()
	var animation = mob_types[randi() % mob_types.size()]
	while animation == "die":
		animation = mob_types[randi() % mob_types.size()]
	$Body.animation = animation
	$Turret/Turret.animation = animation
	angle = rotation
	speed = rand_range(50.0, 150.0)
	target_position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	# if target_position is set, move towards it with a max rotation speed
	# calculate the angle to the target position
	time_since_position_change += delta
	if time_since_position_change > rng.randf_range(1, 5):
		time_since_position_change = 0
		target_position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))
	
	var target_angle = position.angle_to_point(target_position)
	var diff = target_angle - angle
	if diff > PI:
		diff -= 2 * PI
	if diff < -PI:
		diff += 2 * PI
	var rotation_dir = 1
	if diff < 0:
		rotation_dir = -1
	var rotation_amount = min(abs(diff), turn_rotation_speed * delta)
	var angle_change = rotation_amount * rotation_dir
	var move_direction = -1

	angle += angle_change
	angle = fmod(angle, 2 * PI)
	$Body.rotation = angle + PI / 2
	$CollisionShape2D.rotation = angle + PI / 2

	var velocity = Vector2(move_direction, 0).rotated(angle).normalized() * speed * delta
	position += velocity

	if !am_firing:
		$Turret.target_angle = angle + PI / 2
		return

	# point the turret at the player
	var player_position = get_node("/root/Main/Player").position
	var turret_target_angle = position.angle_to_point(player_position)
	$Turret.target_angle = turret_target_angle + PI / 2

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Mob_hit(damage):
	health -= damage
	if health <= 0:
		$Body.scale = Vector2(2, 2)
		$Body.play("die")
		$Turret.hide()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished")
		emit_signal("die", age)

func _on_Body_animation_finished():
	queue_free()

func stop_firing():
	$Turret.fire_rate = 0
	am_firing = false
