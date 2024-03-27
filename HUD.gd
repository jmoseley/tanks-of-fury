extends CanvasLayer

signal start_game

const AIRSTRIKE_TEXTURE = preload("res://art/torpedo.png")

func _ready():
	$LifeBar.hide()
	$ScoreLabel.hide()
	pause_mode = Node.PAUSE_MODE_PROCESS
	$GhostCover.hide()
	$GhostPlayer.hide()
	$PowerupMenu.hide()
	$PowerupMenu.set_items([
		{ 'texture': AIRSTRIKE_TEXTURE, 'title': 'Air Strike', 'id': 'air_strike'},
	])
	player_click_radius = 50

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	$LifeBar.hide()
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	yield($MessageTimer, "timeout")

	$Message.text = "Ready?"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func start():
	$StartButton.hide()
	$Logo.hide()
	$LifeBar.show()
	$ScoreLabel.show()

func _on_StartButton_pressed():
	emit_signal("start_game")

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_Player_on_health_changed(_damage, health):
	$LifeBar/ProgressBar.value = health

export var player_click_radius = 50
var player_dragging = false

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.pressed:
			if (event.position - get_node('/root/Main/Player').position).length() < player_click_radius:
				if !player_dragging:
					player_dragging = true
					$GhostPlayer.show()
					$GhostPlayer.position = event.position
					$GhostPlayer.rotation = get_node('/root/Main/Player').rotation
					$GhostPath.show()
					$GhostPath.clear_points()
					$GhostPath.add_point(get_node('/root/Main/Player').position)
			else:
				$PowerupMenu.open_menu(event.position)
			$GhostCover.show()
			get_tree().paused = true

		else:
			if player_dragging:
				player_dragging = false
				$GhostPlayer.hide()
			$GhostCover.hide()
			get_tree().paused = false

	if player_dragging && (event is InputEventMouseMotion or event is InputEventScreenDrag):
		$GhostPlayer.position = event.position
		# "smoothly" rotate to the mouse move direction
		$GhostPlayer.rotation = lerp_angle($GhostPlayer.rotation, event.speed.angle(), 0.5)
		if $GhostPath.get_point_count() == 0 or ($GhostPath.get_point_position(0) - event.position).length() > 20:
			$GhostPath.add_point(event.position, 0)


func _on_PowerupMenu_item_selected(id:String, position:Vector2):
	print("Powerup selected: ", id, " at ", position)
	var viewport_position = get_viewport().get_canvas_transform().affine_inverse() * position
	print("Viewport position: ", viewport_position)
	match (id):
		'air_strike':
			get_node('/root/Main/AirStrike').shoot(viewport_position)
		_:
			print("Unknown powerup selected: ", id)
	$PowerupMenu.hide()


func _on_PowerupMenu_cancelled():
	$PowerupMenu.hide()
