extends Node2D

var camera_pan
var oven_minigame = preload("res://scenes/oven.tscn")
var running_minigame = preload("res://scenes/runningMiniGame.tscn")
var safe_minigame = preload("res://scenes/safe_minigame.tscn")
var fade_to_black = preload("res://scenes/black_screen_fade.tscn")
var completed_oven = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$map.hide()
	$Cheddar.hide()
	$HUD.hide()
	$Cheddar/Camera2D.enabled = false
	$Cheddar.can_move = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_HUD()
	if Input.is_action_just_pressed("pick_up_item"):
		if abs($Cheddar.position.x - 630) <= 50 and not completed_oven and $Cheddar.items_remaining <= 0:
			oven_minigame_setup()
		elif abs($Cheddar.position.x - 910) <= 50 and completed_oven:
			chase_minigame_setup()

func _on_game_start() -> void:
	$StartScreen.hide()
	$map.show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar/Camera2D.global_position = Vector2(900, 370)
	$Cheddar/Camera2D.enabled = true
	$Directions.show()
	camera_pan = true
	play_sfx('main')
	pan_to_location(750)
	
func oven_minigame_setup(faded=false):
	## Add this to play_sfx() at some point.
	if not faded:
		$GameSFX.stream = load("res://assets/sounds/stove_ignite.mp3")
		$GameSFX.play()
		var black_screen = fade_to_black.instantiate()
		black_screen.text.append("Cheddar valiantly stuffs the stove with kindling & turns on the oven.")
		black_screen.text.append("Before he realizes, however, the cat sneaks up on Cheddar and throws him in!")
		black_screen.text.append("Help Cheddar escape before it's too late!")
		black_screen.faded.connect(oven_minigame_setup.bind(true)) ## Call setup again after black screen has faded.
		black_screen.get_node("Label").text = black_screen.text[0]
		add_child(black_screen)
		
	## Oven minigame setup.
	else:
		var oven = oven_minigame.instantiate()
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
		play_sfx("minigame")
		add_child(oven)

func _on_oven_minigame_win():
	completed_oven = true
	$map.show()
	$StaticBody2D.show()
	$HUD.show()
	$StaticBody2D/CollisionShape2D.disabled = false
	$Cheddar.global_position = Vector2(734, 377)
	$Cheddar/Camera2D.limit_left = 0
	$Cheddar/Camera2D.limit_right = 1022
	$Cheddar/Camera2D.limit_bottom = 382
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$PostOvenText.show()
	for fire in get_tree().get_nodes_in_group("main_flames"):
		fire.show()

func chase_minigame_setup():
	## Running minigame setup.
	var running = running_minigame.instantiate()
	$PostOvenText.hide()
	$Cheddar.position = Vector2(300, 410)
	$Cheddar.scale = Vector2(3,3)
	$Cheddar/Camera2D.enabled = false
	$Cheddar.JUMP_VELOCITY = -500.0
	$Cheddar.running_minigame = true
	$map.hide()
	$StaticBody2D.hide()
	$HUD.hide()
	$StaticBody2D/CollisionShape2D.disabled = true
	for fire in get_tree().get_nodes_in_group("main_flames"):
		fire.hide()
	add_child(running)

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
	audio_player.pitch_scale = audio_player.pitch_scale * pitch
	if not audio_player.playing:
		audio_player.play()
	
	## Fade in music
	while audio_player.volume_db < desired_volume:
		audio_player.volume_db += 2
		await get_tree().create_timer(1.0).timeout
		
func handle_HUD():
	## Handling HUD movement & limits.
	if $Cheddar.position.x <= 760 and $Cheddar.position.x >= 66:
		$HUD.position.x = $Cheddar.position.x
	elif $Cheddar.position.x > 760:
		$HUD.position.x = 759
	elif $Cheddar.position.x < 66:
		$HUD.position.x = 60
	
func pan_to_location(loc, start=1000):
	## Code for initial camera pan to oven.
	while camera_pan:
		await get_tree().create_timer(0.01).timeout
		$Cheddar/Camera2D.global_position.x -= 1
		if $Cheddar/Camera2D.global_position.x <= loc:
			camera_pan = false
			await get_tree().create_timer(2.0).timeout
			$Cheddar/Camera2D.global_position.x = start
			$Cheddar.show()
			$Cheddar.can_move = true
			$HUD.show()
			$Directions.hide()
