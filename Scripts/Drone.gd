extends Control


# Declare member variables here. Examples:
export var flipped = false
export var scale = 2.0
onready var start_x = self.rect_position.x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var next_frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rect_scale = Vector2(scale,scale) 
	$Drone.flip_h = flipped
