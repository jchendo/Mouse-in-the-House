extends CanvasLayer

signal try_again
signal won

@onready var message  = get_node("Message")

var countdown : Timer
var message_timer : Timer
var countdown_message : Label
var restart_button : Button

var game_length = 56 # how long minigame last + 6 seconds for player to read instructions
var time_left = game_length

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown = $CountdownTimer
	message_timer = $MessageTimer
	countdown_message = $CountdownMessage
	restart_button = $RestartButton
	
	countdown_message.text = str(time_left)
	message.text = str("Dodge The Flames & Survive\nUntil The Clock Hits Zero!")
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
		message.show()
		restart_button.show()

func _on_countdown_timer_timeout() -> void:
	if Global.is_alive:
		message.text = str("You Won")
		message.show()
		won.emit()

func _on_message_timer_timeout() -> void:
	message.hide()

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
	message_timer.start(5)
