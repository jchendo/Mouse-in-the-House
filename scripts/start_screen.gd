extends Node2D

signal start
var extra_mouse_scene = preload("res://scenes/mouse_extra.tscn")
var intro_cutscene = preload("res://scenes/intro_cutscene.tscn")
var tutorial_scene = preload("res://scenes/tutorial.tscn")
var fade_scene = preload("res://scenes/black_screen_fade.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var cutscene = intro_cutscene.instantiate()
	cutscene.connect("cutscene_over", on_cutscene_over)
	add_child(cutscene)
	$StartScreenBackground.hide()
	#$TitleText.hide()
	$MouseInTheHouseLogo.hide()
	$StartButton.hide()
	#$ExtraMouseTimer.start()
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tutorial_button_pressed() -> void:
	$Tutorial.disabled = true
	var tutorial = tutorial_scene.instantiate()
	$StartScreenBackground.hide()
	#$TitleText.hide()
	$MouseInTheHouseLogo.hide()
	$StartButton.hide()
	$Wind.stop()
	$Music.stop()
	$ButtonClick.play()
	tutorial.connect("tutorial_finished", _on_tutorial_finished)
	add_child(tutorial)

func  _on_tutorial_finished(): 
	var black_screen = fade_scene.instantiate()
	black_screen.screen_hold_time = 2
	add_child(black_screen)
	await get_tree().create_timer(4.5).timeout
	var tuto = get_node("tutorial")
	tuto.queue_free()
	$Tutorial.disabled = false
	$StartScreenBackground.show()
	$MouseInTheHouseLogo.show()
	$StartButton.show()
	$Wind.play()
	$Music.play()

func _on_start_button_pressed() -> void:
	$StartButton.queue_free()
	$Tutorial.queue_free()
	$ButtonClick.play()
	$StartTimer.start()
	$ExtraMouseTimer.stop()
	## the mouse that will turn around and go back to house
	add_mouse(100, get_viewport_rect().size, true)

func _on_extra_mouse_timeout() -> void:
	## Adds extra mice to run across the screen.
	add_mouse(randf_range(75,125), get_viewport_rect().size)
	
func on_cutscene_over():
	$StartScreenBackground.show()
	#$TitleText.show()
	$MouseInTheHouseLogo.show()
	$StartButton.show()
	$Music.play()
	$Wind.play()
	$ExtraMouseTimer.start()
	
func add_mouse(speed, screensize, is_cheddar=false):
	var mouse = extra_mouse_scene.instantiate()
	var y_pos_scaler = randf_range(screensize[1]-300, screensize[1]-50) / screensize[1] 
	var rng = RandomNumberGenerator.new()
	var random_num = rng.randi_range(1,5)
	mouse.animation = 'run' + str(random_num)
	mouse.title_screen = true ## Starts their movement.
	mouse.scale = Vector2(5,5) * y_pos_scaler ## Size them by distance to front
	mouse.speed = speed
	mouse.position = Vector2(-250, y_pos_scaler * screensize[1])
	if is_cheddar:
		mouse.play("cheddar_run")
		mouse.is_cheddar = true
		mouse.scale = Vector2(7,7) * y_pos_scaler ## Size them by distance to front
		mouse.position = Vector2(-100, y_pos_scaler * screensize[1])
	
	add_child(mouse)
	return mouse
	
func _on_start_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	var black_screen = fade_scene.instantiate()
	black_screen.text = ["In pursuit of fiery revenge, Cheddar ventures back towards his old home one last time..."]
	black_screen.get_node("Label").position.x = -366
	black_screen.font_size = 32
	black_screen.connect("faded", started)
	add_child(black_screen)
	
	tween.tween_property($Music, "volume_db", -20, 1)
func started():
	$Wind.stop()
	$Music.stop()
	start.emit()
