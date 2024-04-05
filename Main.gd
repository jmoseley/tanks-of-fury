extends Node

export(PackedScene) var mob_scene
export(PackedScene) var bullet_scene

func _ready():
	randomize()
	$HUD.show_message("Ready?")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func new_game():
	GameState.new_game()

func _on_StartTimer_timeout():
	$MobTimer.start()

func _on_MobTimer_timeout():
	var num_mobs = get_tree().get_nodes_in_group("mobs").size()
	if num_mobs >= 10:
		return
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobSpawnPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	mob.connect("die", self, "_on_Mob_die")
	mob.connect("hit", self, "_on_Mob_hit")

	# Spawn the mob by adding it to the Main scene.
	$Characters.add_child(mob)

func _on_Player_dead():
	GameState.game_over()

func _on_Player_health_changed(damage, new_health):
	if new_health <= 0:
		get_node("/root/Main/Camera").add_trauma(1)
	else:
		get_node("/root/Main/Camera").add_trauma(damage * 0.05)
