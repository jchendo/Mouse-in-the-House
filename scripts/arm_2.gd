extends Node2D

# Variables to control the movement and rotation
var rotation_speed = 2 
var y_speed = -150   
var speed = 2
var tot = 0            


# Timer to control the flow
var moving_back = false
var done = false
@onready var moving_object = $arm  # Assuming the object is a Sprite

func _process(delta):
	tot += delta * speed
	if tot>4.5:
		if !done:
			moving_object.rotation += rotation_speed * delta
			#moving_object.position.y -= y_speed * delta
			moving_object.position.x += 400 * delta
		
		if moving_object.rotation > 0 and !moving_back:
			done = true
			moving_object.position.x -= speed * 2
			
		if moving_object.position.x <= -450:
			moving_object.position.x = 50.653
			moving_object.position.y = 474.395
			moving_object.rotation = -2.15251994132996
			done = false
