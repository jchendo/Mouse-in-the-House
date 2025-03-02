extends AnimatedSprite2D

@export var SPEED = 75
var title_screen = false
var scared = false
var running = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var colors = ["964B00", "D3D3D3"]
	#modulate = Color(colors[randi_range(0,1)])
	play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if title_screen:
		if animation != 'run':
			play('run')
		position.x += SPEED * delta
		if position.x >= get_viewport_rect().size.x + 30:
			queue_free()
	## When cat enters intro cutscene the mice shake
	elif scared:
		pass ## TODO
	elif running: ## Running away from cat in cutscene.
		var door_coords = Vector2(644,19) ## for directing the mice 
		var direction = position.angle_to_point(door_coords) 
		var true_speed = Vector2(SPEED,0).rotated(direction)
		
		position += true_speed * delta
		
		if abs((door_coords-position)).length() <= 5:
			queue_free()
			

## When jump is called in intro cutscene.
func _on_animation_finished() -> void:
	pass # Replace with function body.
