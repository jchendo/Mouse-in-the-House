extends Node2D

var mice
var black_screen = preload("res://scenes/black_screen_fade.tscn")
var cat_speed = 25
var timeouts = 0
signal cutscene_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MouseExtra3/Bubble/Apple.modulate.a = 0
	$MouseExtra4/Bubble/Cheese.modulate.a = 0
	$Squeaks.play()
	$Cat/Footsteps.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mice = get_tree().get_nodes_in_group("mice") ## Constantly update group in case of removal.
	if get_tree().get_nodes_in_group("mice").is_empty():
		## Fade to black, bring title screen in
		var fade = black_screen.instantiate()
		$Squeaks.stop()
		fade.connect("faded", _on_faded)
		add_child(fade)
		cutscene_over.emit()
		set_process(false)
	
	$Cat.position.x += cat_speed * delta

func _on_cat_hiss_timer_timeout() -> void:
	## Play hiss sound effect.
	$RunTimer.start() ## 2 seconds of jumping before the mice run
	$Cat/Hiss.play()
	$Squeaks.pitch_scale = 1.0
	$Squeaks.volume_db = 5
	$Squeaks.play()
	for mouse in mice:
		mouse.play("jump" + str(mouse.random_num))
		## Show exclamation points & set their size to default.
		$LargeTextBubble.show()


func _on_run_timer_timeout() -> void:
	## Mice run towards door.
	$"Text Bubble Timer".stop()
	$LargeTextBubble.hide()
	cat_speed = 0
	$Cat.play("sleep")
	$Cat/Footsteps.stop()
	for mouse in mice:
		mouse.running = true

func _on_faded():
	queue_free()
			
func _on_cutscene_skip() -> void:
	cutscene_over.emit()
	queue_free()


func _on_text_bubble_timer_timeout() -> void:
	if timeouts == 0:
		$MouseExtra4/Bubble.show()
		fade_alpha($MouseExtra4/Bubble/Cheese)
	elif timeouts == 1:
		fade_alpha($MouseExtra4/Bubble/Cheese, true)
	elif timeouts == 2:
		$MouseExtra3/Bubble.show()
		fade_alpha($MouseExtra3/Bubble/Apple)
		$MouseExtra4/Bubble.hide()
	elif timeouts == 3:
		fade_alpha($MouseExtra3/Bubble/Apple, true)
	else:
		pass
		$MouseExtra3/Bubble.hide()
		$MouseExtra4/Bubble.hide()
	timeouts += 1
	
func fade_alpha(object, rev=false):
	## Fades an object in.
	if not rev:
		while object.modulate.a < 1:
			object.modulate.a += 0.25
			await get_tree().create_timer(0.25).timeout
		await get_tree().create_timer(0.75).timeout
	else:
		while object.modulate.a > 0:
			object.modulate.a -= 0.15
			await get_tree().create_timer(0.25).timeout
		await get_tree().create_timer(0.75).timeout


func _on_squeaks_finished() -> void:
	var rand_pitch = randf_range(0.9, 1.1)
	$Squeaks.pitch_scale = rand_pitch
	await get_tree().create_timer(1).timeout
	#$Squeaks.play()
