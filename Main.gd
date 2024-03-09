extends Node

export(PackedScene) var mob_scene
export(PackedScene) var bullet_scene
var score

signal go_to_position(position)

var game_started = false

func _ready():
	randomize()
	$HUD.show_message("Ready?")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
	get_tree().call_group("mobs", "stop_firing")
	$MobTimer.stop()
	$HUD.show_game_over()
	game_started = false

func new_game():
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Go!")
	game_started = true
	$HUD.start()

func _on_StartTimer_timeout():
	$MobTimer.start()

func _on_MobTimer_timeout():
	var num_mobs = get_tree().get_nodes_in_group("mobs").size()
	if num_mobs >= 10:
		return
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	mob.connect("die", self, "_on_Mob_die")
	mob.connect("hit", self, "_on_Mob_hit")

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _input(event):
	if game_started == false:
		return
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		emit_signal("go_to_position", event.position)
	elif event is InputEventScreenTouch:
		emit_signal("go_to_position", event.position)

func _on_Player_dead():
	game_over()

func _on_Player_health_changed(damage, new_health):
	if new_health <= 0:
		$Camera.add_trauma(1)
	else:
		$Camera.add_trauma(damage * 0.05)

func _on_Mob_die(age):
	score += 100
	score += round(max(10 - age, 0))
	$HUD.update_score(score)

func _on_Mob_hit(damage):
	score += damage
	$HUD.update_score(score)
