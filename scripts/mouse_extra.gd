extends AnimatedSprite2D

@export var speed = 75
var title_screen = false
var scared = false
var running = false
var is_cheddar = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$House.hide()
	play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_cheddar:
		if position.x >= 200:
			## Stops Cheddar, flips him, makes him think of burning house, then run back.
			set_process(false)
			flip_h = true
			play("idle")
			
			await get_tree().create_timer(1.0).timeout
			$House.show()
			await get_tree().create_timer(1.0).timeout
			$House.hide()
			
			speed = -speed * 2
			is_cheddar = false ## So these commands aren't spammed.
			set_process(true)
			
	if title_screen:
		if animation != 'run':
			play('run')
		position.x += speed * delta
		if position.x >= get_viewport_rect().size.x + 30:
			queue_free()
	elif running: ## Running away from cat in cutscene.
		var door_coords = Vector2(644,19) ## for directing the mice 
		var direction = position.angle_to_point(door_coords) 
		var true_speed = Vector2(speed,0).rotated(direction)
		
		position += true_speed * delta
		
		if abs((door_coords-position)).length() <= 5:
			queue_free()
			
