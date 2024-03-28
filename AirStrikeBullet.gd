extends Area2D

export var movement_speed = 700
export var target = Vector2()
export var radius = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape.radius = radius
	$Explosion.hide()
	# place this just above the top of the screen, in global coordinates, transformed for the current camera view
	position.y = (get_viewport().get_canvas_transform().affine_inverse() * Vector2(0, -100)).y

func _process(delta):
	position += (target - position).normalized() * movement_speed * delta
	if position.y >= target.y:
		position = target
		reached_target()

func set_target(new_target):
	target = new_target
	position.x = target.x

func reached_target():
	var bodies = get_overlapping_bodies()
	$RocketBody.hide()
	$Explosion.show()
	$Explosion.play()
	for body in bodies:
		if body.is_in_group("mobs"):
			# damage depends on how far from the target
			var distance = position.distance_to(target)
			# use log to taper damage as distance increases
			var damage = 100 * (1 - log(distance) / log(radius))
			# the velocity is the angle between the target and the position
			var velocity = (target - position).normalized()
			body.emit_signal("hit", damage, position, velocity)
	$Explosion.connect("animation_finished", self, "queue_free", [], CONNECT_ONESHOT)
