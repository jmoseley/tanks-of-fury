extends CanvasLayer

signal start_game

func _ready():
	$LifeBar.hide()
	$ScoreLabel.hide()

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
