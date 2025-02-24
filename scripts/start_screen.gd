extends Node2D

signal start
var extra_mouse_scene = preload("res://scenes/mouse_extra.tscn")
var intro_cutscene = preload("res://scenes/intro_cutscene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cutscene = intro_cutscene.instantiate()
	cutscene.connect("cutscene_over", on_cutscene_over)
	add_child(cutscene)
	$StartScreenBackground.hide()
	$TitleText.hide()
	$StartButton.hide()
	#$ExtraMouseTimer.start()
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	$ButtonClick.play()
	$Music.stop()
	$Wind.stop()
	start.emit()


func _on_extra_mouse_timeout() -> void:
	var speed = randf_range(75, 140)
	var mouse = extra_mouse_scene.instantiate()
	var screensize = get_viewport_rect().size
	var y_pos_scaler = randf_range(screensize[1]-300, screensize[1]-50) / screensize[1] 
	
	mouse.animation = 'run'
	mouse.title_screen = true ## Starts their movement.
	mouse.scale = Vector2(5,5) * y_pos_scaler ## Size them by distance to front
	mouse.SPEED = speed
	mouse.position = Vector2(-250, y_pos_scaler * screensize[1])
	
	add_child(mouse)
	
func on_cutscene_over():
	$StartScreenBackground.show()
	$TitleText.show()
	$StartButton.show()
	$Music.play()
	$Wind.play()
	$ExtraMouseTimer.start()
	
