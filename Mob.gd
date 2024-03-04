extends RigidBody2D

export var health = 100

signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $Body.frames.get_animation_names()
	var animation = mob_types[randi() % mob_types.size()]
	while animation == "die":
		animation = mob_types[randi() % mob_types.size()]
	$Body.animation = animation
	$Turret.animation = animation


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Mob_hit(damage):
	health -= damage
	if health <= 0:
		linear_velocity = Vector2.ZERO
		scale = Vector2(2, 2)
		$Body.play("die")
		$Turret.hide()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished")

func _on_Body_animation_finished():
	queue_free()
