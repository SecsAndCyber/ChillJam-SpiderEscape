extends Area2D

signal hit_enemy(other)

export var walking = false
export var jumping = false
export var steps = 0
export var pivot = 0

var climp_speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	steps = 0

var next_frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pivot > rotation_degrees:
		rotation_degrees = clamp(rotation_degrees + (climp_speed*90)*delta, 0, pivot)
	else:
		rotation_degrees = clamp(rotation_degrees - (climp_speed*90)*delta, pivot, 90)
	if next_frame < OS.get_system_time_msecs():
		next_frame = OS.get_system_time_msecs() + 250
		if jumping:
			$Sprite.frame = 5
		elif walking:
			$Sprite.frame = wrapi($Sprite.frame + 1, 0, 4)
			steps += 1


func _on_Player_body_entered(body):
	print("Hit ", body)
	emit_signal("hit_enemy", body)


func _on_Player_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Hit ", area)
	emit_signal("hit_enemy", area)


func _on_Player_area_entered(area):
	print("Hit ", area)
	emit_signal("hit_enemy", area)
