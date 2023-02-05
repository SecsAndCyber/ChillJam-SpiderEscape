extends Node

signal tapped()
signal hold_started()
signal hold_ended(duration)

var button_pressed = false
var button_held = false
var button_hold_start_time = 0
var button_hold_time = 0
export var button_hold_delay = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var next_frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var now = OS.get_system_time_msecs()
	if Input.is_action_pressed("ui_select"):
		if not button_pressed:
			button_hold_time = now + button_hold_delay
			button_pressed = true
		elif button_hold_time < now:
			if not button_held:
				button_held = true
				button_hold_start_time = now
				emit_signal("hold_started")
	else:
		if button_pressed and button_held:
			emit_signal("hold_ended", now - button_hold_start_time)
			button_pressed = false
			button_held = false
			button_hold_time = 0
			button_hold_start_time = 0
		elif button_pressed:
			emit_signal("tapped")
			button_pressed = false
			button_hold_time = 0


func _on_TouchScreenButton_pressed():
	var now = OS.get_system_time_msecs()
	if not button_pressed:
			button_hold_time = now + button_hold_delay
			button_pressed = true
	elif button_hold_time < now:
		if not button_held:
			button_held = true
			button_hold_start_time = now
			emit_signal("hold_started")


func _on_TouchScreenButton_released():
	var now = OS.get_system_time_msecs()
	if button_pressed and button_held:
			emit_signal("hold_ended", now - button_hold_start_time)
			button_pressed = false
			button_held = false
			button_hold_time = 0
			button_hold_start_time = 0
	elif button_pressed:
		get_node("/root/GameBoard/TouchScreenButton/ScoreSound").play()
		emit_signal("tapped")
		button_pressed = false
		button_hold_time = 0
