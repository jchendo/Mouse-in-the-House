extends Node2D

var camera_pan
var oven_minigame = preload("res://scenes/oven.tscn")
var oven_cutscene = preload("res://scenes/oven_cutscene.tscn")
var running_minigame = preload("res://scenes/runningMiniGame.tscn")
var safe_minigame = preload("res://scenes/safe_minigame.tscn")
var fade_to_black = preload("res://scenes/black_screen_fade.tscn")
var completed_oven = false
var completed_safe = false
@onready var oven_cutscene_timer : Timer = $OvenCutsceneTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$map.hide()
	$safe_minigame.hide()
	$Cheddar.hide()
	$HUD.hide()
	$door.hide()
	$Cheddar/Camera2D.enabled = false
	$Cheddar.can_move = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_HUD()
	if Input.is_action_just_pressed("pick_up_item"):
		if abs($Cheddar.position.x - 630) <= 50 and not completed_oven and $Cheddar.items_remaining <= 0 and $Cheddar.can_interact:
			oven_minigame_setup()
		elif ($Cheddar.position.distance_to($safe_minigame.position)) <= 50 and completed_oven and not completed_safe and $Cheddar.can_interact:
			if $Cheddar.has_paperclip:
				safe_minigame_setup()
			else:
				$HUD.run_narrator("I bet there's something in this safe... if only I had a paperclip.")
		elif abs($Cheddar.position.x - -110) <= 50 and completed_oven and $Cheddar.can_interact:
			if completed_safe:
				chase_minigame_setup()
			else: ## If hasn't gotten the key from the safe yet.
				$HUD.run_narrator("It's locked! Where's a safe spot for a key...")

func _on_game_start() -> void:
	$StartScreen.hide()
	$map.show()
	$door.show()
	$safe_minigame.show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar/Camera2D.global_position = Vector2(900, 370)
	$Cheddar/Camera2D.enabled = true
	$main_cat.show()
	$main_cat.started = true
	$HUD/GoalBar/Label.text = "Goal: Collect Paper"
	camera_pan = true
	play_sfx('main')
	pan_to_location(750)

func oven_minigame_setup(faded=false):
	## Add this to play_sfx() at some point.
	#if not faded:
		#$GameSFX.stream = load("res://assets/sounds/stove_ignite.mp3")
		#$GameSFX.play()
		#var black_screen = fade_to_black.instantiate()
		#black_screen.text.append("Cheddar valiantly stuffs the stove with kindling & turns on the oven.")
		#black_screen.text.append("Before he realizes, however, the cat sneaks up on Cheddar and throws him in!")
		#black_screen.text.append("Help Cheddar escape before it's too late!")
		#$Cheddar/Camera2D.global_position.x = 723
		#black_screen.faded.connect(oven_minigame_setup.bind(true)) ## Call setup again after black screen has faded.
		#black_screen.get_node("Label").text = black_screen.text[0]
		#$Cheddar.can_move = false
		#$main_cat.started = false ## Gets rid of all cat behavior.
		#add_child(black_screen)

	var pre_oven = oven_cutscene.instantiate()
	add_child(pre_oven)
	print(pre_oven)
	oven_cutscene_timer.start() # once timer ends (end of oven cutscene) starts oven minigame
	$Cheddar.can_move = false
	$Cheddar.can_interact = false
	$Cheddar/Camera2D.enabled = false
	$map.hide()
	$StaticBody2D.hide()
	$main_cat.hide()
	$HUD.hide()
	$StaticBody2D/CollisionShape2D.disabled = true


func _on_oven_minigame_win():
	completed_oven = true
	Global.in_oven_minigame = false
	$main_cat.started = true
	$main_cat.show()
	$map.show()
	$StaticBody2D.show()
	$HUD.show()
	handle_HUD()
	$StaticBody2D/CollisionShape2D.disabled = false
	$Cheddar.global_position = Vector2(734, 377)
	$Cheddar/Camera2D.limit_left = 0
	$Cheddar/Camera2D.limit_right = 1022
	$Cheddar/Camera2D.limit_bottom = 382
	$Cheddar.get_node("AnimatedSprite2D/Pickup_label").show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar.can_interact = true
	$HUD.run_narrator("Get out of the house before it burns down!!")
	$PostOvenArrow.show()
	$HUD/GoalBar/Label.text = "Goal: Escape House"
	for fire in get_tree().get_nodes_in_group("main_flames"):
		fire.show()

func _on_oven_minigame_back_pressed():
	#print("back!")
	Global.in_oven_minigame = false
	$map.show()
	$StaticBody2D.show()
	$HUD.show()
	$StaticBody2D/CollisionShape2D.disabled = false
	$Cheddar.global_position = Vector2(734, 377)
	$Cheddar/Camera2D.limit_left = 0
	$Cheddar/Camera2D.limit_right = 1022
	$Cheddar/Camera2D.limit_bottom = 382
	$Cheddar/Camera2D.zoom = Vector2(4,4)

func chase_minigame_setup():
	## Running minigame setup.
	$safe_directions.hide()
	$door.play("open")
	$main_cat.position.x = 250
	$main_cat.speed = 150
	$main_cat.end_game = true
	await get_tree().create_timer(3.5).timeout
	$safe_minigame.hide()
	$main_cat.hide()
	$door.hide()

	var running = running_minigame.instantiate()
	$main_cat.started = false
	$PostOvenArrow.hide()
	$Cheddar.position = Vector2(300, 410)
	$Cheddar.scale = Vector2(4,4)
	$Cheddar/Camera2D.enabled = false
	$Cheddar.JUMP_VELOCITY = -500.0
	$Cheddar.running_minigame = true
	$map.hide()
	$StaticBody2D.hide()
	$HUD.hide()
	$StaticBody2D/CollisionShape2D.disabled = true
	for fire in get_tree().get_nodes_in_group("main_flames"):
		fire.hide()
	running.won_game.connect(victory)
	running.resart_game.connect(restart_game)
	add_child(running)

func safe_minigame_setup():
	camera_zoom(Vector2(12,12), 0.001)
	$safe_minigame.interacted = true
	$safe_minigame.won.connect(on_safe_minigame_win)
	$Cheddar.can_move = false
	$Cheddar/AnimatedSprite2D.play("lockpick")

func on_safe_minigame_win():
	$Cheddar/AnimatedSprite2D.play("idle")
	completed_safe = true
	await get_tree().create_timer(3.0).timeout
	camera_zoom(Vector2(4,4), 0.001)
	$Cheddar.can_move = true

func play_sfx(state):
	## Handles sound effects.
	var bus = ''
	var desired_volume = 0 ## in dB
	var fp = '' ## Different sounds to load.
	var pitch = 1 ## Tempo/pitch change
	match state:
		"main":
			bus = 'Music'
			desired_volume = -15
			fp = "res://assets/sounds/main_game_music.mp3"
			pitch = 1
		"minigame":
			bus = 'Music'
			desired_volume = -15
			fp = "res://assets/sounds/main_game_music.mp3"
			pitch = 1.5
		"interact":
			## TODO: Add more logic for different types of interactions.
			bus = 'SFX'
			fp = "res://assets/sounds/interact.wav"

	var audio_player = get_node("Game" + bus)
	audio_player.stream = load(fp)
	audio_player.pitch_scale = pitch
	if not audio_player.playing:
		audio_player.play()

	## Fade in music
	while audio_player.volume_db < desired_volume:
		audio_player.volume_db += 2
		await get_tree().create_timer(1.0).timeout

func handle_HUD():
	## Handling HUD movement & limits.
	if $Cheddar.position.x <= 752 and $Cheddar.position.x >= 57:
		$HUD.position.x = $Cheddar.position.x + 3
	elif $Cheddar.position.x > 752:
		$HUD.position.x = 751
	elif $Cheddar.position.x < 57:
		$HUD.position.x = 57

func pan_to_location(loc, start=1000):
	## Code for initial camera pan to oven.
	while camera_pan:
		await get_tree().create_timer(0.01).timeout
		$Cheddar/Camera2D.global_position.x -= 1
		if $Cheddar/Camera2D.global_position.x <= loc:
			camera_pan = false
			await get_tree().create_timer(2.5).timeout
			$Cheddar/Camera2D.global_position.x = start
			$Cheddar.show()
			$Cheddar.can_move = true
			$HUD.run_narrator("Hm... I wonder if I could find anything in these drawers to stuff in that oven.")
			$HUD.show()

func camera_zoom(zoom, wait = 0.005, pos = $Cheddar.position):
	while(abs($Cheddar/Camera2D.zoom.distance_to(zoom)) >= 0.1):
		if $Cheddar/Camera2D.zoom < zoom:
			$Cheddar/Camera2D.zoom += Vector2(0.01, 0.01)
		else:
			$Cheddar/Camera2D.zoom -= Vector2(0.01, 0.01)
		await get_tree().create_timer(wait).timeout
	$Cheddar/Camera2D.zoom = zoom

func victory():
	$Cheddar.can_move = false

func restart_game():
	get_tree().reload_current_scene()

func _on_main_cat_player_hit() -> void:
	$Cheddar.collide()


func _on_oven_cutscene_timer_timeout() -> void:
	$GameSFX.stream = load("res://assets/sounds/stove_ignite.mp3")
	$GameSFX.play()
	$main_cat.started = false ## Gets rid of all cat behavior.
	## Oven minigame setup.
	var oven = oven_minigame.instantiate()
	$Cheddar/Camera2D.global_position.x = $Cheddar.global_position.x
	$Cheddar.can_move = true
	$Cheddar/Camera2D.enabled = true
	$main_cat.hide()
	$map.hide()
	$StaticBody2D.hide()
	$HUD.hide()
	$StaticBody2D/CollisionShape2D.disabled = true
	$Cheddar.position = Vector2(613, 410)
	$Cheddar/Camera2D.zoom = Vector2(3,3)
	$Cheddar/Camera2D.limit_left = 510
	$Cheddar/Camera2D.limit_bottom = 550
	$Cheddar/Camera2D.limit_right = 930
	oven.get_node("OvenHUD").connect("won", _on_oven_minigame_win)
	oven.get_node("OvenHUD").connect("back", _on_oven_minigame_back_pressed)
	play_sfx("minigame")
	add_child(oven)
