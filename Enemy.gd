extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $Body.sprite_frames.get_animation_names()
	var random_type = randi() % mob_types.size()
	$Body.play(mob_types[random_type])
	$Turret.play(mob_types[random_type])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
