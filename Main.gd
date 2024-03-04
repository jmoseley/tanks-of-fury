extends Node

export(PackedScene) var mob_scene
export(PackedScene) var bullet_scene
var score

signal go_to_position(position)

func _ready():
	randomize()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
	$MobTimer.stop()
	new_game()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_StartTimer_timeout():
	$MobTimer.start()
	_on_MobTimer_timeout()
	
func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	mob.add_to_group("mobs")

func _on_Turret_shoot(position, rotation):
	# Create a new instance of the Bullet scene.
	var bullet = bullet_scene.instance()

	# Set the bullet's position to the turret's position.
	bullet.position = position
	# Set the bullet's direction to the turret's rotation.
	bullet.rotation = rotation
	bullet.velocity = Vector2(0, -1000).rotated(bullet.rotation)

	# Add the bullet to the Main scene.
	add_child(bullet)
	bullet.add_to_group("bullets")

func _input(event):
   # Mouse in viewport coordinates.
   if event is InputEventMouseButton:
	   print("Mouse Click/Unclick at: ", event.position)
	   emit_signal("go_to_position", event.position)
   elif event is InputEventScreenTouch:
	   print("Touch at: ", event.position)
	   emit_signal("go_to_position", event.position)
