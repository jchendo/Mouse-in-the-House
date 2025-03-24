extends Node

@export var fire_scene : PackedScene

var speed : float
const START_SPEED : float = 4.0
var screen_size : Vector2i
var ground_height : int
var fires : Array
var spacebar_pressed = false
var time = 0
var game_started = false

## Camera shake params:
var shake_strength = 30.0
var shake_fade = 5.0

func _ready() -> void:
	$lost_label/ColorRect/Button.process_mode = Node.PROCESS_MODE_ALWAYS
	screen_size = get_window().size
	ground_height = $newGround.get_node("Sprite2D").texture.get_height()
	new_game()
	

func new_game():
	for fire in fires:
		if is_instance_valid(fire):
			fire.queue_free()
	time = 0
	%ProgressBar.value = 0
	spacebar_pressed = false
	$startLabel.text = "Escape from the cat!
Your friends are so close!

Use the space bar to jump and survive"

func _process(delta: float) -> void:
	
	if game_started:
		time += delta * speed
		%ProgressBar.value = time
		if %ProgressBar.value >= 100:
			win_game()
	
	if Input.is_action_pressed("jump") and not spacebar_pressed:  
		spacebar_pressed = true
		$fireTimer.start()
		$startLabel.text = "Goodluck!"
	
	speed = START_SPEED
	
	$Camera2D.position.x += speed
	
	$arm1.position.x += speed
	$arm2.position.x += speed
	$headCat.position.x += speed
	$startLabel.position.x += speed
	$ProgressBar.position.x += speed
	$boundary.position.x += speed
	
	for fire in fires:
		if is_instance_valid(fire):
			fire.position.x -= speed / 2
			if fire.position.x < $boundary/CollisionShape2D.position.x:
				fires.erase(fire)
				fire.queue_free()
	#invisibleGround
	if $Camera2D.position.x - $newGround.position.x > screen_size.x * 1.5:
		$newGround.position.x += screen_size.x


func _on_fire_timer_timeout():
	$startLabel.text = ""
	game_started = true
	generate_fire()
	
func generate_fire():
	var fire = fire_scene.instantiate()

	# Get the camera position and screen size
	var camera_position = $Camera2D.position
	var screen_size = get_viewport().get_visible_rect().size
	
	# Spawn the fire outside the right edge of the screen
	fire.position.x = camera_position.x + screen_size.x / 2 + 100  # Adjusted for the screen's right side
	fire.position.y = ground_height - 120
	
	fire.hit.connect(lose_game)
	add_child(fire)
	fires.append(fire)
	
func lose_game():
	$lost_label.visible = true
	get_tree().paused = true
	
func win_game():
	$Stomp.stop()
	$win_label.visible = true
	get_tree().paused = true	


func _on_button_pressed() -> void:
	get_tree().paused = false
	$lost_label.visible = false
	$fireTimer.stop()
	game_started = false
	new_game()

func camera_shake():
	## Generates offset to make it not so uniform.
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-30.0, 30.0), rng.randf_range(-30.0, 30.0))


func _on_camera_shake_timer_timeout() -> void:
	## lerpf is interpolating the position between the values given.
	## causes shaking effect
	lerpf(shake_strength, 0, shake_fade * (1/60)) ## Doesn't work yet, will fix it later - Jacob
	$Stomp.play()
