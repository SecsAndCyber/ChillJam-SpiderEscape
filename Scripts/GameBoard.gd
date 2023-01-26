extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var screen_size = get_viewport().size
onready var spider_floor = $ScrollingMap/Ceiling.rect_position.y
onready var score_box = $ScrollingMap/Score
var can_climb = true
var dropping = false
var dead = false
export var fall_distance = 0
export var gravity = 10
var screen_speed = 500
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ParallaxBackground/ParallaxLayer.motion_mirroring.x = 4 * $ParallaxBackground/ParallaxLayer/IceCaveLevel1.texture.get_width()
	$ParallaxBackground/DroneLayer.motion_mirroring.x = .95 * $ParallaxBackground/ParallaxLayer.motion_mirroring.x
	$SpiderBox/Player/Sprite.flip_v = true
	$SpiderBox/Player.walking = true
	$ScrollingMap/RestartButton.disabled = true
	$ScrollingMap/RestartButton.hide()

var next_frame = 0
var next_level = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	if not dead:
		score_box.text = "Score: %s\nSteps: %s" % [int(score), $SpiderBox/Player.steps]
		$SpiderBox/WebPoint/Drone.scale = score / 20
	else:
		score_box.text = "RESTART\nScore: %s\nSteps: %s" % [int(score), $SpiderBox/Player.steps]
	if next_level < OS.get_system_time_msecs():
		next_level = OS.get_system_time_msecs() + 1000 * 15
		screen_speed += 150
		
	if next_frame < OS.get_system_time_msecs():
		next_frame = OS.get_system_time_msecs() + 25
		if not dead:
			$ParallaxBackground.scroll_offset.x -= screen_speed * delta
		if dropping:
			fall_distance += 15
			
		if $SpiderBox/Player.jumping and fall_distance < 14:
			fall_distance = 0
			if not dead and can_climb:
				if abs($SpiderBox.rect_position.y - spider_floor) < 5:
					$SpiderBox.rect_position.y = spider_floor
					$SpiderBox/Player.jumping = false
				else:
					$SpiderBox.rect_position.y = lerp($SpiderBox.rect_position.y, spider_floor, (.75 * gravity) * delta)
		elif fall_distance:
			$SpiderBox/Player.jumping = true
			var target = $SpiderBox.rect_position.y + fall_distance
			$SpiderBox.rect_position.y = lerp($SpiderBox.rect_position.y, target, gravity * delta)
			fall_distance =  abs($SpiderBox.rect_position.y - target)

func _draw():
	if not dead and $SpiderBox/Player.jumping:
		draw_line(
					$ScrollingMap/Ceiling/WebPoint.rect_global_position, 
					$SpiderBox/WebPoint.rect_global_position,
					Color(255, 255, 255), 2
				)

var dead_taps = 0
func _on_Controller_tapped():
	if not dead:
		fall_distance = 75
		can_climb = true
	else:
		dead_taps += 1
		if dead_taps > 2:
			get_tree().change_scene("res://Scenes/GameBoard.tscn")

func _on_Controller_hold_started():
	if not dead:
		if not $SpiderBox/Player.jumping and fall_distance < 2:
			dropping = true
		else:
			can_climb = false

func _on_Controller_hold_ended(_duration):
	if not dead:
		dropping = false
		can_climb = true

func _on_Player_hit_enemy(other):
	if other.get_name() == "Score":
		score += .5
		return
	print("Hit ", other)
	if not dead:
		$ScrollingMap/RestartButton.disabled = false
		$ScrollingMap/RestartButton.show()
		$ScrollingMap.remove_child(score_box)
		$ScrollingMap/RestartButton.add_child(score_box)
		score_box.rect_position = Vector2(4,4)
		dropping = true
		dead = true
		can_climb = false
		$SpiderBox/Player.walking = false
		$ParallaxBackground/ParallaxLayer/IceCaveLevel1.modulate = Color(.75, 0, 0)
		$SpiderBox/Player/Sprite.modulate = Color(.25, 0, 0)
	if other.get_name() == "Floor":
		dropping = false

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/GameBoard.tscn")
