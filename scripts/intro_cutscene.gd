extends Node2D

var mice
var black_screen = preload("res://scenes/black_screen_fade.tscn")
var cat_speed = 25
var timeouts = 0
signal cutscene_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_process(false)
	var fade = black_screen.instantiate()
	fade.reverse = true
	fade.wait_time = 10
	fade.faded.connect(on_first_fade)
	add_child(fade)
	Global.print_text($intro_text)
	$SFX.play()
	set_process(false)
	fade_alpha($intro_text, true, 0.05, 4.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mice = get_tree().get_nodes_in_group("mice") ## Constantly update group in case of removal.
	if get_tree().get_nodes_in_group("mice").is_empty():
		## Fade to black, bring title screen in
		var fade = black_screen.instantiate()
		$SFX.stop()
		$RunTimer.stop()
		fade.connect("faded", on_second_fade)
		$Cat.play("idle")
		add_child(fade)
		cutscene_over.emit()
		set_process(false)
	
	$Cat.position.x += cat_speed * delta

func _on_cat_hiss_timer_timeout() -> void:
	## Play hiss sound effect.
	mice = get_tree().get_nodes_in_group("mice")
	$SFX.stream = load("res://assets/sounds/mouse_squeak.mp3")
	$RunTimer.start() ## 2 seconds of jumping before the mice run
	$Cat/Hiss.play()
	$Cat.play("hiss_walk")
	$SFX.pitch_scale = 1.0
	$SFX.volume_db = 5
	$SFX.play()
	for mouse in mice:
		mouse.play("jump" + str(mouse.random_num))
		## Show exclamation points & set their size to default.
		$LargeTextBubble.show()


func _on_run_timer_timeout() -> void:
	## Mice run towards door.
	$TextBubbleTimer.stop()
	$LargeTextBubble.hide()
	cat_speed = 0
	$Cat.play("hiss")
	$Cat/Footsteps.stop()
	for mouse in mice:
		mouse.running = true

func on_first_fade():
	$TextBubbleTimer.start()
	$MouseExtra3/Bubble/Apple.modulate.a = 0
	$MouseExtra4/Bubble/Cheese.modulate.a = 0
	$SFX.stream = load("res://assets/sounds/mouse_squeak.mp3")
	$SFX.play()
	$Cat/Footsteps.play() 
	set_process(true)

func on_second_fade():
	queue_free()
			
func _on_cutscene_skip() -> void:
	cutscene_over.emit()
	$intro_text.visible_ratio = 1
	queue_free()


func _on_text_bubble_timer_timeout() -> void:
	$TextBubbleTimer.wait_time = 0.75
	if timeouts == 0:
		$MouseExtra4/Bubble.show()
		fade_alpha($MouseExtra4/Bubble/Cheese, false, 0.5)
	elif timeouts == 1:
		fade_alpha($MouseExtra4/Bubble/Cheese, true, 0.5)
	elif timeouts == 2:
		$MouseExtra3/Bubble.show()
		fade_alpha($MouseExtra3/Bubble/Apple, false, 0.5)
		$MouseExtra4/Bubble.hide()
	elif timeouts == 3:
		fade_alpha($MouseExtra3/Bubble/Apple, true, 0.5)
	else:
		$MouseExtra3/Bubble.hide()
		$MouseExtra4/Bubble.hide()
	timeouts += 1
	
func fade_alpha(object, rev=false, speed = 0.25, wait = 0.0):
	## Fades an object in.
	var done = false
	await get_tree().create_timer(wait).timeout 
	if not rev:
		while not done:
			if is_instance_valid(object):
				object.modulate.a += speed
				if object.modulate.a == 1:
					done = true
				await get_tree().create_timer(0.25).timeout
			else:
				done = true
		await get_tree().create_timer(0.75).timeout
	else:
		while not done:
			if is_instance_valid(object):
				object.modulate.a -= speed
				if object.modulate.a == 0:
					done = true
				await get_tree().create_timer(0.25).timeout
			else:
				done = true
		await get_tree().create_timer(0.75).timeout


func _on_squeaks_finished() -> void:
	var rand_pitch = randf_range(0.9, 1.1)
	$SFX.pitch_scale = rand_pitch
	await get_tree().create_timer(1).timeout
	#$Squeaks.play()
