extends CanvasLayer

signal start_game

func _ready():
	$LifeBar.hide()
	$ScoreLabel.hide()
	pause_mode = Node.PAUSE_MODE_PROCESS
	$GhostCover.hide()
	$GhostPlayer.hide()

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

export var player_click_radius = 100
var player_dragging = false

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if (event.position - get_node('/root/Main/Player').position).length() < player_click_radius:
			if event.pressed && !player_dragging:
				get_tree().paused = true
				player_dragging = true
				$GhostPlayer.show()
				$GhostPlayer.position = event.position
				$GhostCover.show()
				$GhostPlayer.rotation = get_node('/root/Main/Player').rotation
				$GhostPath.show()
				$GhostPath.clear_points()
				$GhostPath.add_point(get_node('/root/Main/Player').position)

		if !event.pressed && player_dragging:
			player_dragging = false
			get_tree().paused = false
			$GhostPlayer.hide()
			$GhostCover.hide()
			# $GhostPath.hide()

	if player_dragging && (event is InputEventMouseMotion or event is InputEventScreenDrag):
		$GhostPlayer.position = event.position
		# "smoothly" rotate to the mouse move direction
		$GhostPlayer.rotation = lerp_angle($GhostPlayer.rotation, event.speed.angle(), 0.5)
		if $GhostPath.get_point_count() == 0 or ($GhostPath.get_point_position(0) - event.position).length() > 20:
			$GhostPath.add_point(event.position, 0)
