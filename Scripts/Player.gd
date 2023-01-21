extends Area2D

signal hit_enemy(other)

export var walking = false
export var jumping = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var next_frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next_frame < OS.get_system_time_msecs():
		next_frame = OS.get_system_time_msecs() + 250
		if jumping:
			$Sprite.frame = 5
		elif walking:
			$Sprite.frame = wrapi($Sprite.frame + 1, 0, 4)


func _on_Player_body_entered(body):
	print("Hit ", body)
	emit_signal("hit_enemy", body)


func _on_Player_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Hit ", area)
	emit_signal("hit_enemy", area)


func _on_Player_area_entered(area):
	print("Hit ", area)
	emit_signal("hit_enemy", area)
