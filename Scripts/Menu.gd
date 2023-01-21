extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var screen_size = get_viewport().size


# Called when the node enters the scene tree for the first time.
func _ready():
	$SpiderBox/Player.walking = true

var next_frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next_frame < OS.get_system_time_msecs():
		next_frame = OS.get_system_time_msecs() + 25
		if $SpiderBox/Player.walking:
			$SpiderBox.rect_position.x = wrapi($SpiderBox.rect_position.x + 5,0,screen_size.x)


func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/GameBoard.tscn")


func _on_Controller_tapped():
	print("_on_Controller_tapped")


func _on_Controller_hold_started():
	$SpiderBox/Player.walking = false


func _on_Controller_hold_ended(duration):
	$SpiderBox/Player.walking = true
