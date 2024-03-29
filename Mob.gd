extends KinematicBody2D

export var health = 100
export var rotation_speed = 3
export var speed = 0

signal hit(damage, location, velocity)
signal die(age)

var angle = 0
var rng = RandomNumberGenerator.new()

var time_since_position_change = INF
var next_position_change = INF
var target_position = Vector2.ZERO
var am_firing = true
var age = 0
var movement_velocity = Vector2.ZERO
var impulse_velocity = Vector2.ZERO

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
	next_position_change = rand_range(1, 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	# if target_position is set, move towards it with a max rotation speed
	# calculate the angle to the target position
	time_since_position_change += delta
	if time_since_position_change > next_position_change:
		time_since_position_change = 0
		next_position_change = rand_range(1, 5)
		target_position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))

	if am_firing:
		$Turret.target_position = get_node("/root/Main/Player").global_position
	else:
		$Turret.target_position = Vector2.INF

func control(delta):
	if (target_position - position).length() < 100:
		target_position = Vector2.INF
	else:
		# calculate the angle to the target position
		var angle_difference = get_angle_to(target_position) - PI / 2

		if angle_difference > PI:
			angle_difference -= 2 * PI
		elif angle_difference < - PI:
			angle_difference += 2 * PI

		var rotation_dir = 1
		if angle_difference < 0:
			rotation_dir = -1

		var rotation_amount = min(abs(angle_difference), rotation_speed * delta)
		rotation += rotation_dir * rotation_amount
		movement_velocity = Vector2(0, 1).rotated(rotation).normalized()

func _physics_process(delta):
	control(delta)
	move_and_slide(movement_velocity * speed + impulse_velocity)
	movement_velocity = Vector2(0, 1).rotated(rotation).normalized() * movement_velocity.linear_interpolate(Vector2(), 0.1).length()
	impulse_velocity = impulse_velocity.linear_interpolate(Vector2(), 0.1)

func apply_impulse(direction, force):
	impulse_velocity += direction.normalized() * force

func _on_Mob_hit(damage, location, velocity):
	apply_impulse(velocity, damage * 10)
	health -= damage
	if health <= 0:
		$Body.scale = Vector2(2, 2)
		$Body.play("die")
		$Turret.hide()
		$Body.connect("animation_finished", self, "queue_free", [], CONNECT_ONESHOT)
		emit_signal("die", age)

func stop_firing():
	$Turret.fire_rate = 0
	am_firing = false
