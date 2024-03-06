extends Node2D

export var speed = 400 # How fast the player will move (pixels/sec).
export var health = 100
var screen_size # Size of the game window.
export var rotation_speed = 5

signal hit(damage)
signal dead

func _ready():
	screen_size = get_viewport_rect().size
	$Turret/Turret.animation = 'green'
	$Body.animation = 'green'
	hide()

# don't use the rotation property, because only the body rotates, not the entire node
export var angle = PI / 2
var target_position = Vector2.INF

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation_dir = 0
	if Input.is_action_pressed("turn_left"):
		rotation_dir -= 1
		target_position = Vector2.INF
	if Input.is_action_pressed("turn_right"):
		rotation_dir += 1
		target_position = Vector2.INF
	var angle_change = rotation_dir * rotation_speed * delta

	var move_direction = 0
	if Input.is_action_pressed("move_forward"):
		move_direction -= 1
		target_position = Vector2.INF
	if Input.is_action_pressed("move_backward"):
		move_direction += 1
		target_position = Vector2.INF

	# if target_position is set, move towards it with a max rotation speed
	if target_position != Vector2.INF:
		if (target_position - position).length() < 10:
			position = target_position
			target_position = Vector2.INF
			move_direction = 0
		else:
			# calculate the angle to the target position
			var target_angle = (target_position - position).angle()
			var diff = target_angle - angle
			if diff > PI:
				diff -= 2 * PI
			if diff < -PI:
				diff += 2 * PI
			rotation_dir = -1
			if diff < 0:
				rotation_dir = 1
			var rotation_amount = min(abs(diff), rotation_speed * delta)
			angle_change = rotation_amount * rotation_dir
			move_direction = -1

	angle += angle_change
	angle = fmod(angle, 2 * PI)
	$Body.rotation = angle + PI / 2
	$CollisionShape2D.rotation = angle + PI / 2

	var velocity = Vector2(move_direction, 0).rotated(angle).normalized() * speed * delta
	position += velocity
	
	# if the player fully moves outside the screen, wrap around
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

	# aim towards the nearest enemy
	var mobs = get_tree().get_nodes_in_group("mobs")
	var nearest_mob = null
	# set the initial distance to infinity
	var nearest_mob_distance = float("inf")
	for mob in mobs:
		var distance = position.distance_squared_to(mob.global_position)
		if distance < nearest_mob_distance or not nearest_mob:
			nearest_mob = mob
			nearest_mob_distance = distance
	
	var target_angle = angle
	if nearest_mob:
		# change the angle of the turret to aim at the nearest enemy, with a maximum rotation speed
		target_angle = position.angle_to_point(nearest_mob.global_position)
	$Turret.target_angle = target_angle + PI / 2

func start(pos):
	position = pos
	rotation = 0
	health = 100
	angle = PI / 2
	show()
	$Turret.show()
	$Body.animation = 'green'
	$CollisionShape2D.disabled = false

func _on_Main_go_to_position(position):
	target_position = position

func _on_Player_hit(damage):
	health -= damage
	if health <= 0:
		$Body.animation = 'die'
		$Body.play()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished")
		$Turret.hide()
		$CollisionShape2D.set_deferred("disabled", true)

func _on_Body_animation_finished():
	emit_signal("dead")
