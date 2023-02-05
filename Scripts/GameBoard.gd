extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var screen_size = get_viewport().size
onready var spider_floor = $ScrollingMap/Ceiling.rect_position.y
onready var score_box = $ScrollingMap/Score
onready var score_box_location = score_box.rect_position

var can_climb = true
var dropping = false
var dead = false
export var fall_distance = 0
export var gravity = .1
var drone_speed = 100
var crawl_speed = 200
var score = 0
var midpoint = null

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

func _process(delta):
	update()
	if not dead:
		score_box.text = "Score: %s\nSteps: %s" % [int(score), $SpiderBox/Player.steps]
	else:
		score_box.text = "RESTART\nScore: %s\nSteps: %s" % [int(score), $SpiderBox/Player.steps]
	
func _physics_process(delta):
	if not $ParallaxBackground/BackgroundSound.playing:
		$ParallaxBackground/BackgroundSound.play()
	if not dead:
		$SpiderBox/Drone.scale = clamp(score / 20,0, 1.5)
		$ParallaxBackground/BackgroundSound.pitch_scale = clamp(score / 20, .01, 2)
		
		$ParallaxBackground.get_node("DroneLayer").motion_offset.x -= (crawl_speed + drone_speed) * delta
		if not $SpiderBox/Player.jumping:
			$ParallaxBackground.get_node("ParallaxLayer").motion_offset.x -= (crawl_speed) * delta
			
	if next_level < OS.get_system_time_msecs():
		next_level = OS.get_system_time_msecs() + 1000 * 15
		crawl_speed += 10
		drone_speed += 5
		
	if next_frame < OS.get_system_time_msecs():
		next_frame = OS.get_system_time_msecs() + 25
		if dropping:
			fall_distance += 1500 * delta
		if midpoint:
			midpoint.x = $ScrollingMap/Ceiling/WebPoint.rect_global_position.x
			
		if fall_distance > 15:
			if not $SpiderBox/FallingSound.playing:
				$SpiderBox/FallingSound.play()
			
		if $SpiderBox/Player.jumping and fall_distance < 14:
			fall_distance = 0
			if $SpiderBox/FallingSound.playing:
				$SpiderBox/FallingSound.stop()
			if not dead and can_climb:
				if abs($SpiderBox.rect_position.y - spider_floor) < 5:
					midpoint = null
					$SpiderBox.rect_position.y = spider_floor
					$SpiderBox/Player.jumping = false
					$SpiderBox/Player.pivot = 0
				else:
					if not midpoint:
						midpoint = $SpiderBox/Player.get_node("Sprite/WebPoint").rect_global_position
					$SpiderBox/Player.pivot = -90
					$SpiderBox.rect_position.y = clamp(
												$SpiderBox.rect_position.y - ((.75 * gravity) / delta),
												spider_floor,
												$SpiderBox.rect_position.y)
		elif fall_distance:
			$SpiderBox/Player.jumping = true
			var target = $SpiderBox.rect_position.y + fall_distance
			$SpiderBox.rect_position.y = clamp(
												$SpiderBox.rect_position.y + ((gravity) / delta),
												$SpiderBox.rect_position.y,
												target)
			fall_distance =  abs($SpiderBox.rect_position.y - target)
			if midpoint and midpoint.y < $SpiderBox/Player.get_node("Sprite/WebPoint").rect_global_position.y:
				midpoint = null

func _draw():
	if not dead and $SpiderBox/Player.jumping:
		if midpoint:
			draw_line(
						$ScrollingMap/Ceiling/WebPoint.rect_global_position, 
						midpoint,
						Color(255, 255, 255), 2
					)
			draw_line(
						midpoint, 
						$SpiderBox/Player.get_node("Sprite/WebPoint").rect_global_position,
						Color(255, 255, 255), 2
				)
		else:			
			draw_line( 
					$ScrollingMap/Ceiling/WebPoint.rect_global_position, 
					$SpiderBox/Player.get_node("Sprite/WebPoint").rect_global_position,
					Color(255, 255, 255), 2
				)

var dead_taps = 0
func _on_Controller_tapped():
	if not dead:
		$SpiderBox/Player.pivot = 90
		fall_distance = 80
		can_climb = true
	else:
		dead_taps += 1
		if dead_taps > 2:
			get_tree().change_scene("res://Scenes/GameBoard.tscn")

func _on_Controller_hold_started():
	if not dead:
		if not $SpiderBox/Player.jumping and fall_distance < 2:
			midpoint = null
			$SpiderBox/Player.pivot = 90
			dropping = true
		else:
			if not midpoint:
				midpoint = $SpiderBox/Player.get_node("Sprite/WebPoint").rect_global_position
			can_climb = false

func _on_Controller_hold_ended(_duration):
	if not dead:
		$SpiderBox/Player.pivot = -90
		dropping = false
		can_climb = true
		fall_distance = 0

func _on_Player_hit_enemy(other):
	if other.get_name() == "Warning":
		if not $SpiderBox/SpottedSound.playing:
			$SpiderBox/SpottedSound.play()
		return
	if other.get_name() == "Score":
		score += .5
		if not $SpiderBox/ScoreSound.playing:
			$SpiderBox/ScoreSound.play()
		return
	print("Hit ", other)
	if not dead:
		if not $SpiderBox/ImpactSound.playing:
			$SpiderBox/ImpactSound.play()
		$ScrollingMap/RestartButton.disabled = false
		$ScrollingMap/RestartButton.show()
		$ScrollingMap.remove_child(score_box)
		$ScrollingMap/RestartButton.add_child(score_box)
		score_box.rect_position = Vector2(4,4)
		score_box.rect_scale = Vector2(2,2)
		dropping = true
		dead = true
		can_climb = false
		$SpiderBox/Player.walking = false
		$ParallaxBackground/ParallaxLayer/IceCaveLevel1.modulate = Color(.75, 0, 0)
		$SpiderBox/Player/Sprite.modulate = Color(.25, 0, 0)
	if other.get_name() == "Floor":
		if not $SpiderBox/ImpactSound.playing:
			$SpiderBox/ImpactSound.play()
			
		if dropping:
			if $SpiderBox/Player.pivot > 0:
				$SpiderBox/Player.pivot -= 90
			if dropping and $SpiderBox/Player.pivot < 0:
				$SpiderBox/Player.pivot += 90
		dropping = false
		fall_distance = 0

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/GameBoard.tscn")
