extends Node2D

const AIRSTRIKE_TEXTURE = preload ("res://art/torpedo.png")

func _ready():
	player_click_radius = 50
	get_node("/root/Main/HUD/GhostCover").hide()
	$GhostPlayer.hide()
	get_node('/root/Main/HUD/PowerupMenu').hide()
	get_node('/root/Main/HUD/PowerupMenu').set_items([
		{'texture': AIRSTRIKE_TEXTURE, 'title': 'Air Strike', 'id': 'air_strike'},
	])
	get_node('/root/Main/HUD/PowerupMenu').pause_mode = Node.PAUSE_MODE_PROCESS
	pause_mode = Node.PAUSE_MODE_PROCESS

var player_dragging = false
var camera_speed = 800
var last_drag_position = Vector2()
var last_global_position = Vector2()

func _process(delta):
	# move the camera if the player is dragging and near the edges of the screen
	if player_dragging:
		var camera: Camera2D = get_node("/root/Main/Camera")
		var global_position = get_viewport().get_canvas_transform().affine_inverse() * last_drag_position
		var viewport_size = get_viewport().size
		var camera_position = camera.global_position
		if last_drag_position.x < 200:
			camera_position.x -= min(camera_speed * (1 - last_drag_position.x / 200), camera_speed) * delta
		if last_drag_position.x > viewport_size.x - 200:
			camera_position.x += min(camera_speed * (1 - (viewport_size.x - last_drag_position.x) / 200), camera_speed) * delta
		if last_drag_position.y < 200:
			camera_position.y -= min(camera_speed * (1 - last_drag_position.y / 200), camera_speed) * delta
		if last_drag_position.y > viewport_size.y - 200:
			camera_position.y += min(camera_speed * (1 - (viewport_size.y - last_drag_position.y) / 200), camera_speed) * delta
		camera.global_position = camera_position
		$GhostPlayer.position = global_position
		$GhostPlayer.rotation = lerp_angle($GhostPlayer.rotation, (global_position - last_global_position).angle(), 0.2)
		if $GhostPath.get_point_count() == 0 or ($GhostPath.get_point_position(0) - global_position).length() > 20:
			$GhostPath.add_point(global_position, 0)
		last_global_position = global_position

func _on_PowerupMenu_item_selected(id: String, position: Vector2):
	var viewport_position = get_viewport().get_canvas_transform().affine_inverse() * position
	match (id):
		'air_strike':
			get_node('/root/Main/AirStrike').shoot(viewport_position)
		_:
			print("Unknown powerup selected: ", id)
	get_node('/root/Main/HUD/PowerupMenu').hide()

func _on_PowerupMenu_cancelled():
	get_node('/root/Main/HUD/PowerupMenu').hide()

export var player_click_radius = 50

func _input(event):
	var camera: Camera2D = get_node("/root/Main/Camera")
	# Mouse in viewport coordinates.
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.pressed:
			var global_position = get_viewport().get_canvas_transform().affine_inverse() * event.position
			if (global_position - get_node('/root/Main/Player').position).length() < player_click_radius:
				if !player_dragging:
					player_dragging = true
					$GhostPlayer.show()
					$GhostPlayer.position = global_position
					$GhostPlayer.rotation = get_node('/root/Main/Player').rotation
					$GhostPath.show()
					$GhostPath.clear_points()
					$GhostPath.add_point(get_node('/root/Main/Player').position)
					camera.global_position = global_position
					last_drag_position = event.position
					camera.smoothing_enabled = false
			else:
				get_node('/root/Main/HUD/PowerupMenu').open_menu(event.position)
			get_node("/root/Main/HUD/GhostCover").show()
			get_tree().paused = true

		else:
			if player_dragging:
				player_dragging = false
				$GhostPlayer.hide()
			get_node("/root/Main/HUD/GhostCover").hide()
			get_tree().paused = false
			camera.smoothing_enabled = true

	if player_dragging&&(event is InputEventMouseMotion or event is InputEventScreenDrag):
		last_drag_position = event.position
