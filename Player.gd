extends Node2D

export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
export var rotation_speed = 5

signal hit

func _ready():
	screen_size = get_viewport_rect().size
	hide()

# don't use the rotation property, because only the body rotates, not the entire node
export var angle = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation_dir = 0
	if Input.is_action_pressed("turn_left"):
		rotation_dir -= 1
		target_position = Vector2.INF
	if Input.is_action_pressed("turn_right"):
		rotation_dir += 1
		target_position = Vector2.INF
	angle += rotation_dir * rotation_speed * delta

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
			angle += rotation_amount * rotation_dir
			move_direction = -1

	# set rotation of child Body
	$Body.rotation = angle

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

func start(pos):
	position = pos
	rotation = PI / 2
	show()
	$Body/CollisionShape2D.disabled = false

func _on_Player_body_entered(body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$Body/CollisionShape2D.set_deferred("disabled", true)

var target_position = Vector2.INF
func _on_Main_go_to_position(position):
	target_position = position
