extends Area2D

export var health = 100
export var turn_rotation_speed = 5
export var turret_rotation_speed = 7
export var speed = 0

signal hit(damage)

var angle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $Body.frames.get_animation_names()
	var animation = mob_types[randi() % mob_types.size()]
	while animation == "die":
		animation = mob_types[randi() % mob_types.size()]
	$Body.animation = animation
	$Turret.animation = animation
	angle = rotation
	speed = rand_range(150.0, 250.0)

	# point at the player to start, with a little variation
	var target_position = get_node("/root/Main/Player").position
	var target_angle = (target_position - position).angle()
	angle = target_angle + rand_range(-PI / 4, PI / 4)
	$Body.rotation = angle + PI / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if target_position is set, move towards it with a max rotation speed
	# calculate the angle to the target position
	var target_position = get_node("/root/Main/Player").position
	var target_angle = (target_position - position).angle()
	var diff = target_angle - angle
	if diff > PI:
		diff -= 2 * PI
	if diff < -PI:
		diff += 2 * PI
	var rotation_dir = -1
	if diff < 0:
		rotation_dir = 1
	var rotation_amount = min(abs(diff), turn_rotation_speed * delta)
	angle += rotation_amount * rotation_dir
	var move_direction = -1

	angle = fmod(angle, 2 * PI)

	# set rotation of child Body
	$Body.rotation = angle + PI / 2

	var velocity = Vector2(move_direction, 0).rotated(angle).normalized() * speed * delta
	position += velocity


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Mob_hit(damage):
	health -= damage
	if health <= 0:
		$Body.scale = Vector2(2, 2)
		$Body.play("die")
		$Turret.hide()
		$Body.connect("animation_finished", self, "_on_Body_animation_finished")

func _on_Body_animation_finished():
	queue_free()
