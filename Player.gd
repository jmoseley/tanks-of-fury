extends KinematicBody2D

export var speed = 400 # How fast the player will move (pixels/sec).
export var health = 100
var screen_size # Size of the game window.
export var rotation_speed = 5
export var fire_rate = 1.0

signal hit(damage, location, angle)
signal on_health_changed(damage, health)
signal dead

func _ready():
	screen_size = get_viewport_rect().size
	$Turret/Turret.animation = 'green'
	$Body.animation = 'green'
	hide()
	$Turret.fire_rate = 0
	set_health(100)

func _process(delta):
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

var target_position = Vector2.INF
var velocity = Vector2()
var is_reversing = false

func control(delta):
	var rotation_dir = 0
	if Input.is_action_pressed("turn_left"):
		rotation_dir = -1
		target_position = Vector2.INF
	if Input.is_action_pressed("turn_right"):
		rotation_dir = 1
		target_position = Vector2.INF
	rotation += rotation_dir * rotation_speed * delta

	if Input.is_action_pressed("move_forward"):
		is_reversing = false
		velocity = Vector2(0, 1).rotated(rotation).normalized()
		target_position = Vector2.INF
	if Input.is_action_pressed("move_backward"):
		is_reversing = true
		target_position = Vector2.INF
		velocity = Vector2(0, -1).rotated(rotation).normalized() / 2

	# if target_position is set, move towards it with a max rotation speed
	if target_position != Vector2.INF:
		is_reversing = false
		if (target_position - position).length() < 100:
			target_position = Vector2.INF
		else:
			# calculate the angle to the target position
			var angle_difference = get_angle_to(target_position) - PI / 2

			if angle_difference > PI:
				angle_difference -= 2 * PI
			elif angle_difference < -PI:
				angle_difference += 2 * PI
			
			rotation_dir = 1
			if angle_difference < 0:
				rotation_dir = -1
			
			var rotation_amount = min(abs(angle_difference), rotation_speed * delta)
			rotation += rotation_dir * rotation_amount
			velocity = Vector2(0, 1).rotated(rotation).normalized()

func _physics_process(delta):
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	control(delta)
	move_and_slide(velocity * speed)
	velocity = Vector2(0, -1 if is_reversing else 1).rotated(rotation).normalized() * velocity.linear_interpolate(Vector2(), 0.1).length()

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

func _on_Main_go_to_position(position):
	target_position = position

func _on_Player_hit(damage, location, velocity):
	# apply_impulse(global_position - location, velocity)
	decrement_health(damage)
	if health <= 0:
		rotation = 0
		$Body.animation = 'die'
		$Body.scale = Vector2(2, 2)
		$Body.play()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished")
		$Turret.hide()
		$CollisionShape2D.set_deferred("disabled", true)

func _on_Body_animation_finished():
	emit_signal("dead")
	$Body.disconnect("animation_finished", self, "_on_Body_animation_finished")
	$Body.stop()
	$Body.scale = Vector2(0.75, 0.75)
	hide()
