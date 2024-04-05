extends Node

enum MobType {BOMBER, FIGHTER}

# Manage game state
# - waves of enemies
# - restarting the game after player dies

export var wave = 1

var hud: CanvasLayer = null
var wave_timer: Timer = null
var start_timer: Timer = null
var score = 0
export var game_running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	hud = get_node('/root/Main/HUD')
	wave_timer = Timer.new()
	add_child(wave_timer)
	wave_timer.wait_time = 30
	wave_timer.connect("timeout", self, "_on_wave_timer_timeout")
	wave_timer.one_shot = true
	start_timer = Timer.new()
	add_child(start_timer)
	start_timer.stop()
	start_timer.wait_time = 3
	start_timer.connect("timeout", self, "start_wave")
	start_timer.one_shot = true

func start_wave():
	hud.show_message('Wave ' + str(wave))
	game_running = true
	wave_timer.wait_time = 15 + wave
	wave_timer.start()
	for _i in range(wave * 3):
		spawn(MobType.FIGHTER)
	if wave > 3:
		for _i in range(wave / 2):
			spawn(MobType.BOMBER)

func game_over():
	game_running = false
	get_tree().call_group("mobs", "stop_firing")
	hud.show_game_over()
	get_node("/root/Main/Characters/Path").clear_points()
	wave_timer.stop()
	start_timer.stop()

func new_game():
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	score = 0
	get_node("/root/Main/Characters/Player").start(get_node("/root/Main/StartPosition").position)
	hud.update_score(score)
	hud.start()
	wave = 1
	start_timer.start()

func _on_wave_timer_timeout():
	next_wave();

func next_wave():
	score += wave * 500
	game_running = false
	get_node("/root/Main/Characters/Path").clear_points()
	wave += 1
	start_timer.start()
	wave_timer.stop()

func _process(_delta):
	if !start_timer.is_stopped():
		hud.show_message(str(round(start_timer.time_left)))
	if game_running&&get_tree().get_nodes_in_group("mobs").size() == 0:
		next_wave()

func spawn(type):
	# Create a new instance of the Mob scene.
	var mob = get_node("/root/Main/").mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("/root/Main/MobSpawnPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	mob.connect("die", self, "on_mob_die")
	mob.connect("hit", self, "on_mob_hit")
	mob.set_type(type)

	# Spawn the mob by adding it to the Main scene.
	get_node("/root/Main/Characters").add_child(mob)

func on_mob_die(age):
	score += 100
	score += round(max(10 - age, 0))
	hud.update_score(score)

func on_mob_hit(damage, _location, _velocity):
	score += clamp(damage, 0, 100)
	hud.update_score(score)