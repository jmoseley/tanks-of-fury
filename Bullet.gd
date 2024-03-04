extends Area2D

export var velocity = Vector2.ZERO
export var damage = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bullet_body_entered(body):
	# if this is an enemy, emit a signal to it
	if body.is_in_group("mobs"):
		body.emit_signal("hit", damage)
		queue_free()
