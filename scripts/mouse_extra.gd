extends AnimatedSprite2D

@export var speed = 75
var title_screen = false
var scared = false
var running = false
var is_cheddar = false
var rng = RandomNumberGenerator.new()
var random_num = rng.randi_range(1,5)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$House.hide()
	$Thought_Bubble.hide()
	if not is_cheddar:
		play("idle" + str(random_num))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_cheddar:
		if position.x >= 200:
			## Stops Cheddar, flips him, makes him think of burning house, then run back.
			set_process(false)
			flip_h = true
			play("cheddar_idle")
			$Thought_Bubble.show()
			$Thought_Bubble.play("bubble")
			await get_tree().create_timer(1.0).timeout
			$House.show()
			await get_tree().create_timer(1.0).timeout
			$House.hide()
			$Thought_Bubble.hide()
			speed = -speed * 2
			play("cheddar_run")
			is_cheddar = false ## So these commands aren't spammed.
			set_process(true)
			
	if title_screen:
		if animation != 'cheddar_run':
			play('run'+str(random_num))
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
			
	
