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


	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	mob.add_to_group("mobs")

func _input(event):
   # Mouse in viewport coordinates.
   if event is InputEventMouseButton:
	   print("Mouse Click/Unclick at: ", event.position)
	   emit_signal("go_to_position", event.position)
   elif event is InputEventScreenTouch:
	   print("Touch at: ", event.position)
	   emit_signal("go_to_position", event.position)
