extends Node2D

var velocity = 2 ## Moving bar speed.
var slot_offset = 37 ## how many pixels apart are slots
var slot_num = 0	
var num_attempts = 3 ## How many mistakes the player gets before losing.
var length = 30
@onready var slot : ColorRect = $slot_1_bg
@onready var hud : Node2D = $safe_hud
@onready var button : Button = hud.get_node('option')
signal failed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Setup
	hud.get_node("title").text = "Pick the Lock!"
	hud.get_node("sub_title").text = "You have " + str(num_attempts) + " attempts and " + str(length) + " seconds to pick the lock. Fail, and the cat will find you!" 
	hud.get_node("option").text = "Start"
	button.connect("pressed", _on_button_pressed)
	Global.print_text(hud.get_node("sub_title"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $moving_bar.position.x < 15:
		velocity = -velocity
	elif $moving_bar.position.x > 270:
		velocity = -velocity
		
	if Input.is_action_just_pressed("lockpick"):
		if in_green():
			slot.hide()
			slot = get_tree().get_nodes_in_group("slots")[slot_num]
			slot_num+=1
			$moving_bar.position.y += slot_offset
			velocity += 2
		else: 
			num_attempts -= 1
			if num_attempts == 0:
				failed.emit()
	$moving_bar.position.x += velocity

func in_green():
	## If the cursor is in the green, delete & switch to next slot.
	var green = slot.get_node("green")
	if ($moving_bar.position.x > green.position.x
	and $moving_bar.position.x < green.position.x + green.size.x):
		return true
	return false


func _on_countdown() -> void:
	$countdown.text = str(int($countdown.text)-1)
	if $countdown.text == str(0):
		failed.emit()

func _on_button_pressed():
	match button.text:
		"Start":
			hud.hide()
		"Try again?":
			hud.hide()
			reset_game()

func _on_failed() -> void:
	## Editing HUD to display loss text.
	hud.get_node("title").text = 'YOU LOSE!'
	## If failed on attempts, or on time
	if num_attempts == 0:
		hud.get_node("sub_title").text = "All your fidgeting with the lock allowed the cat to find you. Cheddar's fate is unknown..."
	else:
		hud.get_node("sub_title").text = "You didn't make it in time! The cat finally found you -- Cheddar's fate is unknown..."
	button.text = "Try again?"
	Global.print_text(hud.get_node("sub_title"))
	hud.show()

func reset_game():
	$moving_bar.position = Vector2(216, 14) ## Just the starting position.
	velocity = 2
	length = 30
	num_attempts = 3
	for slot in get_tree().get_nodes_in_group("slots"):
		slot.show()
		
