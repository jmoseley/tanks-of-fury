extends RigidBody2D

export var health = 100

signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $Body.frames.get_animation_names()
	var animation = mob_types[randi() % mob_types.size()]
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
		queue_free()
