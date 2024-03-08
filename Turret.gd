extends Node2D

export var fire_rate = 1.0 # shots per second
export var rotation_speed = 7 # radians per second
export var target_angle = 0
export var damage_dealt = 10
export var target_group = "mobs"
export var bullet_speed = 1000
export(PackedScene) var bullet_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var time_since_last_shot = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# every frame, add the time since the last frame to the time since the last shot
	time_since_last_shot += delta

	# todo: if the delta is too large, then the time since the last shot will be greater than the fire rate

	# rotate the turret towards the target angle with a maximum rotation speed, turning the shortest direction
	var angle_difference = target_angle - rotation
	if angle_difference > PI:
		angle_difference -= 2 * PI

	if angle_difference < -PI:
		angle_difference += 2 * PI

	var rotation_direction = 1
	if angle_difference < 0:
		rotation_direction = -1

	var rotation_amount = min(abs(angle_difference), rotation_speed * delta)
	rotation += rotation_amount * rotation_direction

	if is_visible() && fire_rate > 0 && time_since_last_shot > 1.0 / fire_rate && abs(angle_difference) < PI / 8:
		shoot()
		time_since_last_shot = 0

func shoot():
	# Create a new instance of the Bullet scene.
	var bullet = bullet_scene.instance()

	# Set the bullet's position to the turret's position.
	bullet.position = global_position
	# Set the bullet's direction to the turret's rotation.
	bullet.rotation = rotation
	bullet.velocity = Vector2(0, bullet_speed).rotated(bullet.rotation)
	bullet.damage = damage_dealt
	bullet.target_group = target_group
	bullet.get_node("AnimatedSprite").animation = $Turret.animation

	# Add the bullet to the Main scene.
	get_tree().get_root().add_child(bullet)
