extends Control

export var label_text = ''
var timer_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func start(label, timer):
	$Label.text  = label_text
	timer_instance = timer

func process(delta):
	if timer_instance:
		$TextureProgress.value = timer_instance.time_left / timer_instance.wait_time
