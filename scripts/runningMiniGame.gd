extends Node

@export var fire_scene : PackedScene

@export var tree_scene : PackedScene

@export var mouses : PackedScene

@export var rocks : PackedScene

@export var can : PackedScene

@export var bush : PackedScene


var speed : float
const START_SPEED : float = 4.0
var screen_size : Vector2i
var ground_height : int
var objects_arr : Array
var spacebar_pressed = false
var time = 0
var game_started = false
var start_end_screen = false
var final_scene = false
var objects : Array

## Camera shake params:
var shake_strength = 30.0
var shake_fade = 5.0

signal won_game
signal resart_game

func _ready() -> void:
	$lost_label/ColorRect/Button.process_mode = Node.PROCESS_MODE_ALWAYS
	screen_size = get_window().size
	ground_height = $newGround.get_node("Sprite2D").texture.get_height()
	if bush != null:
		objects.append(bush)
	if can != null:
		objects.append(can)
	if rocks != null:
		objects.append(rocks)
	new_game()
	

func new_game():
	for object in objects_arr:
		if is_instance_valid(object):
			object.queue_free()
	time = 0
	%ProgressBar.value = 0
	spacebar_pressed = false
	$startLabel.text = "Escape from the cat!
Your friends are so close!

Use the space bar to jump and survive"

func _process(delta: float) -> void:
	
	if game_started:
		time += delta * speed
		%ProgressBar.value = time * 10 
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
	
	for object in objects_arr:
		if is_instance_valid(object):
			object.position.x -= speed / 2
			if object.position.x < $boundary/CollisionShape2D.position.x:
				objects_arr.erase(object)
				object.queue_free()
	#invisibleGround
	if $Camera2D.position.x - $newGround.position.x > screen_size.x * 1.5:
		$newGround.position.x += screen_size.x


func _on_fire_timer_timeout():
	$startLabel.text = ""
	game_started = true
	generate_random_object()
	
func generate_random_object():
	var object_grab = objects[randi() % objects.size()]
	print(object_grab)
	var object_scene = object_grab.instantiate()

	# Get the camera position and screen size
	var camera_position = $Camera2D.position
	var screen_size = get_viewport().get_visible_rect().size
	
	# Spawn the fire outside the right edge of the screen
	object_scene.position.x = camera_position.x + screen_size.x / 2 + 100  # Adjusted for the screen's right side
	object_scene.position.y = ground_height - 90
	
	object_scene.hit.connect(lose_game)
	add_child(object_scene)
	objects_arr.append(object_scene)

func generate_tree():
	var tree = tree_scene.instantiate()

	# Get the camera position and screen size
	var camera_position = $Camera2D.position
	var screen_size = get_viewport().get_visible_rect().size
	
	# Spawn the tree outside the right edge of the screen
	tree.position.x = camera_position.x + screen_size.x / 2 + 100  # Adjusted for the screen's right side
	tree.position.y = ground_height - 550
	
	tree.z_index = 100
	
	add_child(tree)
	
func lose_game():
	if start_end_screen:
		return
	$lost_label.visible = true
	get_tree().paused = true
	
func win_game():
	$Stomp.stop()
	$fireTimer.stop()
	$CameraShakeTimer.stop()
	$ProgressBar.visible = false
	$arm1.position.x -= speed - 2
	$arm2.position.x -= speed - 2
	$headCat.position.x -= speed - 2
	$boundary.visible = false
	if !start_end_screen:
		start_end_screen = true
		generate_tree()
		$gameTimer.start()
		$mouseTimer.start()
	if final_scene:
		$Camera2D.position.x -= speed
		won_game.emit()
		$winLabel.visible = true
		$arm1.position.x -= speed
		$arm2.position.x -= speed
		$headCat.position.x -= speed
		


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


func _on_game_timer_timeout() -> void:
	final_scene = true


func _on_mouse_timer_timeout() -> void:
	var mouses = mouses.instantiate()

	# Get the camera position and screen size
	var camera_position = $Camera2D.position
	var screen_size = get_viewport().get_visible_rect().size
	
	# Spawn the tree outside the right edge of the screen
	mouses.position.x = camera_position.x + screen_size.x / 2 + 100  # Adjusted for the screen's right side
	mouses.position.y = ground_height 
	mouses.scale = Vector2(4,4)
	
	add_child(mouses)


func _on_reset_button_pressed() -> void:
	resart_game.emit()
