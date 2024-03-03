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
	if Input.is_action_pressed("turn_right"):
		rotation_dir += 1
	angle += rotation_dir * rotation_speed * delta

	# set rotation of child Body
	$Body.rotation = angle

	var move_direction = 0
	if Input.is_action_pressed("move_forward"):
		move_direction -= 1
	if Input.is_action_pressed("move_backward"):
		move_direction += 1

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
