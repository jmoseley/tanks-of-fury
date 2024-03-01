extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

var angle = 0
@export var rotation_speed = 5 # rads/sec?

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2() # The player's movement vector.

	if Input.is_action_pressed("rotate_right"):
		angle += rotation_speed * delta
		rotation = angle
	if Input.is_action_pressed("rotate_left"):
		angle -= rotation_speed * delta
		rotation = angle
	if Input.is_action_pressed("move_forward"):
		# rotate by 90 degrees
		velocity = Vector2(1, 0).rotated(angle + PI/2).normalized() * speed
	if Input.is_action_pressed("move_backward"):
		velocity = Vector2(-1, 0).rotated(angle + PI/2).normalized() * speed

	# Move the player.
	velocity = velocity * delta
	position += velocity

	# move the player to the other side of the screen if it goes off the screen, including the width of the player
	if position.x > screen_size.x + 16:
		position.x = -16
	if position.x < -16:
		position.x = screen_size.x + 16
	if position.y > screen_size.y + 16:
		position.y = -16
	if position.y < -16:
		position.y = screen_size.y + 16


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
