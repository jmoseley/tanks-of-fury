extends KinematicBody2D

export var speed = 300 # How fast the player will move (pixels/sec).
export var health = 1000
var screen_size # Size of the game window.
export var rotation_speed = 5
export var fire_rate = 5.0

signal hit(damage, location, angle)
signal on_health_changed(damage, health)
signal dead

func _ready():
	screen_size = get_viewport_rect().size
	$Turret/Turret.animation = 'green'
	$Body.animation = 'green'
	hide()
	$Turret.fire_rate = 0
	$Turret.damage_dealt = 3
	set_health(100)

func _process(_delta):
	var nearest_mob = null
	var min_distance = INF
	for mob in get_tree().get_nodes_in_group("mobs"):
		var distance = mob.global_position.distance_to(position)
		if !nearest_mob || distance < min_distance:
			min_distance = distance
			nearest_mob = mob
	if nearest_mob:
		# change the angle of the turret to aim at the nearest enemy, with a maximum rotation speed
		$Turret.fire_rate = fire_rate
		$Turret.target_position = nearest_mob.global_position
	else:
		$Turret.fire_rate = 0
		$Turret.target_position = Vector2.INF

var movement_velocity = Vector2()
var is_reversing = false
var impulse_velocity = Vector2()

func control(delta):
	if health <= 0:
		return

	var rotation_dir = 0
	var pressed = false
	if Input.is_action_pressed("turn_left"):
		rotation_dir = -1
		pressed = true
	if Input.is_action_pressed("turn_right"):
		rotation_dir = 1
		pressed = true
	rotation += rotation_dir * rotation_speed * delta

	if Input.is_action_pressed("move_forward"):
		is_reversing = false
		pressed = true
		movement_velocity = Vector2(0, 1).rotated(rotation).normalized() * speed
	if Input.is_action_pressed("move_backward"):
		is_reversing = true
		pressed = true
		movement_velocity = Vector2(0, -1).rotated(rotation).normalized() / 2 * speed
	return pressed

func _physics_process(delta):
	var keyboard = control(delta)

	if health <= 0:
		return

	var path : Line2D = get_node("/root/Main/HUD/GhostPath")
	if keyboard:
		path.clear_points()
	else:
		if path.points.size() > 0:
			var target = path.points[path.points.size()-1]
			if position.distance_to(target) < 3:
				path.remove_point(path.points.size()-1)
				if path.points.size() > 0:
					target = path.points[path.points.size()-1]
				else:
					target = position
			movement_velocity = (target - position).normalized() * speed

	move_and_slide(movement_velocity + impulse_velocity)
	if !keyboard && movement_velocity.length() > 0:
		rotation = lerp_angle(rotation, movement_velocity.angle() - PI/2, 0.2)
	movement_velocity = movement_velocity.linear_interpolate(Vector2(), 0.3)
	impulse_velocity = impulse_velocity.linear_interpolate(Vector2(), 0.1)

func apply_impulse(direction, force):
	impulse_velocity += direction.normalized() * force

func set_health(h):
	health = h
	emit_signal("on_health_changed", 0, health)

func decrement_health(damage):
	health -= damage
	emit_signal("on_health_changed", damage, health)

func start(pos):
	position = pos
	rotation = 0
	set_health(100)
	show()
	$Turret.show()
	rotation = PI
	$Turret.rotation = 0
	$Body.animation = 'green'
	$CollisionShape2D.disabled = false

func _on_Player_hit(damage, _location, velocity):
	apply_impulse(velocity, damage * 10)
	decrement_health(damage)
	if health <= 0:
		rotation = 0
		movement_velocity = Vector2()
		impulse_velocity = Vector2()
		$Body.animation = 'die'
		$Body.scale = Vector2(2, 2)
		$Body.play()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished", [], CONNECT_ONESHOT)
		$Turret.hide()
		$CollisionShape2D.set_deferred("disabled", true)

func _on_Body_animation_finished():
	emit_signal("dead")
	$Body.stop()
	$Body.scale = Vector2(0.75, 0.75)
	hide()

func crate_acquired():
	pass
