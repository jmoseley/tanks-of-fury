extends Area2D

export var velocity = Vector2.ZERO
export var damage = 50
export var target_group = "mobs"

# Called when the node enters the scene tree for the first time.
func _ready():

	add_to_group("bullets")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bullet_body_entered(body):
	# if this is an enemy, emit a signal to it
	if body.is_in_group(target_group):
		body.emit_signal("hit", damage)
		$AnimatedSprite.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
		velocity = Vector2.ZERO

func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_Bullet_area_entered(area):
	# if this is an enemy, emit a signal to it
	if area.is_in_group(target_group):
		area.emit_signal("hit", damage)
		$AnimatedSprite.play("explosion")
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
		velocity = Vector2.ZERO
