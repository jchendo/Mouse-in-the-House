extends CanvasLayer

signal try_again
signal won

@onready var message  = get_node("Message")

var countdown : Timer
var message_timer : Timer
var countdown_message : Label
var restart_button : Button
var text_background: Sprite2D

var game_length = 36 # how long minigame last + 6 seconds for player to read instructions
var time_left = game_length

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown = $CountdownTimer
	message_timer = $MessageTimer
	countdown_message = $CountdownMessage
	restart_button = $RestartButton
	text_background = $TextBG
	
	countdown_message.text = str(time_left)
	message.text = str("Dodge The Flames & Survive\nUntil The Clock Hits Zero!")
	text_background.scale = Vector2(27, 6)
	text_background.position = Vector2(641, 267)
	restart_button.hide()
	message_timer.start(5)
	countdown.start(game_length)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_left > 0 and Global.is_alive:
		time_left -= delta
		countdown_message.text = str(int(time_left))
	
	if Global.is_alive == false:
		message.text = str("Game Over")
		handle_oven_sfx("dead")
		text_background.scale = Vector2(12, 3)
		text_background.position = Vector2(640, 247)
		text_background.show()
		message.show()
		restart_button.show()

func _on_countdown_timer_timeout() -> void:
	if Global.is_alive:
		message.text = str("You Won")
		text_background.scale = Vector2(12, 3)
		text_background.position = Vector2(640, 247)
		text_background.show()
		message.show()
		won.emit()

func _on_message_timer_timeout() -> void:
	message.hide()
	text_background.hide()
	handle_oven_sfx("alive")

func _on_restart_button_pressed() -> void:
	restart_button.hide()
	try_again.emit()
	
	Global.is_alive = true
	
	# restart timer
	time_left = game_length
	countdown_message.text = str(time_left)
	countdown.start(game_length)
	
	# restart message instructions
	message.text = str("Dodge The Flames & Survive\nUntil The Clock Hits Zero!")
	text_background.scale = Vector2(27, 6)
	text_background.position = Vector2(641, 267)
	message_timer.start(5)

func handle_oven_sfx(state):
	var fp = ''
	var volume = -20 # in dB
	match state:
		"dead":
			fp = "res://assets/sounds/oven_dying.wav"
			volume = -10
		"alive":
			fp = "res://assets/sounds/fire_sound.wav"
	## Ensures we only play the death sound once by checking to make sure it is not already being played.
	if $OvenSFX.stream != load(fp): 
		$OvenSFX.stream = load(fp)
		$OvenSFX.volume_db = volume
		$OvenSFX.play()
