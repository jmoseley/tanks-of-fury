extends Node2D

const AIRSTRIKE_TEXTURE = preload ("res://art/torpedo.png")

var player_dragging = false
var camera_speed = 700
var last_drag_position = Vector2()
var viewport_size = Vector2()

var cover: CanvasLayer
var ghost_player: Area2D
var ghost_path: Line2D
var powerup_menu
var player: KinematicBody2D
var camera: Camera2D

func _ready():
	player_click_radius = 50
	cover = get_node("/root/Main/GhostCover")
	cover.hide()
	ghost_player = get_node("/root/Main/GhostPlayerLayer/GhostPlayer")
	ghost_player.hide()
	ghost_path = get_node("/root/Main/Characters/GhostPath")
	powerup_menu = get_node('/root/Main/HUD/PowerupMenu')
	powerup_menu.hide()
	print(powerup_menu)
	powerup_menu.set_items([
		{'texture': AIRSTRIKE_TEXTURE, 'title': 'Air Strike', 'id': 'air_strike'},
	])
	powerup_menu.pause_mode = Node.PAUSE_MODE_PROCESS
	player = get_node("/root/Main/Characters/Player")
	pause_mode = Node.PAUSE_MODE_PROCESS
	viewport_size = get_viewport_rect().size
	camera = get_node("/root/Main/Camera")

var camera_scroll_edge_size = 0.2 # 20% of the screen size

func _process(delta):
	# move the camera if the player is dragging and near the edges of the screen
	if player_dragging:
		var global_position = get_viewport().get_canvas_transform().affine_inverse() * last_drag_position
		var camera_position = camera.global_position
		if last_drag_position.x < viewport_size.x * camera_scroll_edge_size:
			# faster speed when closer to the edge
			camera_position.x -= clamp(camera_speed * (1 - last_drag_position.x / (viewport_size.x * camera_scroll_edge_size)), 0, camera_speed) * delta
		if last_drag_position.x > viewport_size.x * (1 - camera_scroll_edge_size):
			camera_position.x += clamp(camera_speed * (1 - (viewport_size.x - last_drag_position.x) / (viewport_size.x * camera_scroll_edge_size)), 0, camera_speed) * delta
		if last_drag_position.y < viewport_size.y * camera_scroll_edge_size:
			camera_position.y -= clamp(camera_speed * (1 - last_drag_position.y / (viewport_size.y * camera_scroll_edge_size)), 0, camera_speed) * delta
		if last_drag_position.y > viewport_size.y * (1 - camera_scroll_edge_size):
			camera_position.y += clamp(camera_speed * (1 - (viewport_size.y - last_drag_position.y) / (viewport_size.y * camera_scroll_edge_size)), 0, camera_speed) * delta
		camera.global_position = camera_position
		ghost_player.position = global_position
		ghost_player.rotation = lerp_angle(ghost_player.rotation, (global_position - ghost_path.get_point_position(0)).angle(), 0.2)
		if ghost_path.get_point_count() == 0 or (ghost_path.get_point_position(0) - global_position).length() > 20:
			ghost_path.add_point(global_position, 0)

func _on_PowerupMenu_item_selected(id: String, position: Vector2):
	var viewport_position = get_viewport().get_canvas_transform().affine_inverse() * position
	match (id):
		'air_strike':
			get_node('/root/Main/AirStrike').shoot(viewport_position)
		_:
			print("Unknown powerup selected: ", id)
	powerup_menu.hide()

func _on_PowerupMenu_cancelled():
	powerup_menu.hide()

export var player_click_radius = 100

func _input(event):
	if player.health <= 0:
		return
	# Mouse in viewport coordinates.
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.position.x < 0 or event.position.y < 0 or event.position.x > viewport_size.x or event.position.y > viewport_size.y:
			return
		if event.pressed:
			var global_position = get_viewport().get_canvas_transform().affine_inverse() * event.position
			if (global_position - player.position).length() < player_click_radius:
				if !player_dragging:
					player_dragging = true
					ghost_player.show()
					ghost_player.position = global_position
					ghost_player.rotation = player.rotation
					ghost_path.show()
					ghost_path.clear_points()
					ghost_path.add_point(player.position)
					camera.global_position = global_position
					camera.smoothing_enabled = false
					last_drag_position = event.position
					cover.show()
					get_tree().paused = true
			else:
				powerup_menu.open_menu(event.position)
				cover.show()
				get_tree().paused = true

		else:
			if player_dragging:
				player_dragging = false
				ghost_player.hide()
			cover.hide()
			get_tree().paused = false
			camera.smoothing_enabled = true

	if event is InputEventScreenDrag:
		if player_dragging:
			print("update Dragging player", event.position)
			last_drag_position = event.position
