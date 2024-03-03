extends RigidBody2D

export var health = 100


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
