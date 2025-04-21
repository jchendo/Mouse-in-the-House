extends Node2D

var velocity = 2 ## Moving bar speed.
var slot_offset = 37.5 ## how many pixels apart are slots
var slot_num = 0
var num_slots = 4 
var length = 40
var part = 0
var percent_open = 0
var interacted = false
var has_won = false
@onready var slot : ColorRect = $slot_1_bg
@onready var hud : Node2D = $safe_hud
@onready var button : Button = hud.get_node('option')
signal failed
signal won
signal next ## Two parts of the minigame, signals the switch.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Setup
	hud.get_node("title").text = "Pick the Lock!"
	hud.get_node("sub_title").text = ("You have " + str(length) 
								   + " seconds to pick the lock. Fail, and the cat will find you!" 
								   + " Use [SPACE] to stop the lockpick in the GREEN AREA.") 
	hud.get_node("option").text = "START"
	button.connect("pressed", _on_button_pressed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interacted:
		hud.show()
		Global.print_text(hud.get_node("sub_title"))
		interacted = false
		part = 1
	if part == 1:         
		if $moving_bar.position.x < 15:
			velocity = -velocity
		elif $moving_bar.position.x > 270:
			velocity = -velocity
			
		if Input.is_action_just_pressed("lockpick"):
			slot = get_tree().get_nodes_in_group("slots")[slot_num]
			if in_green():
				$lock_click.play()
				slot.hide()
				if slot_num + 1 < num_slots:
					slot_num+=1
					$moving_bar.position.y += slot_offset
					velocity += 2
				else:
					next.emit()
			else: 
				if slot_num >= 1:
					slot_num -= 1
					slot = get_tree().get_nodes_in_group("slots")[slot_num]
					slot.show()
					$moving_bar.position.y -= slot_offset
		$moving_bar.position.x += velocity
	elif part == 2: ## Part 2
		if Input.is_action_just_pressed("lockpick"): ## Spam space to open safe
			percent_open += 0.08
		percent_open -= 0.001
		if percent_open > 1:
			percent_open = 1
			if !has_won:
				has_won = true
				won.emit()
		$second_part/bar.size.x = percent_open * 285
		$second_part/percent.value = percent_open * 100

func in_green():
	## If the cursor is in the green, delete & switch to next slot.
	var green = slot.get_node("green")
	if ($moving_bar.position.x > green.position.x - 10
	and $moving_bar.position.x < green.position.x + green.size.x + 10):
		return true
	return false


func _on_countdown() -> void:
	$countdown.text = str(int($countdown.text)-1)
	get_tree().get_nodes_in_group("slots")[slot_num].get_node("green").show()
	if $countdown.text == str(0):
		failed.emit()

func _on_button_pressed():
	match button.text:
		"START":
			hud.hide()
			$SFX.play()
			start_game()
		"Try again?":
			hud.hide()
			reset_game()
		"CONTINUE":
			hud.hide()

func start_game():
	for _slot in get_tree().get_nodes_in_group("slots"):
		_slot.show()
	$countdown/countdown_timer.start()
	$countdown.show()
	$moving_bar.show()
	$background/contrast_screen.show()

func _on_failed() -> void:
	$SFX.stop()
	$countdown/countdown_timer.stop()
	$background/contrast_screen.hide()
	$second_part.hide()
	part = 0
	$countdown.hide()
	$moving_bar.hide()
	## Editing HUD to display loss text.
	hud.get_node("title").text = 'YOU LOSE!'
	## If failed on attempts, or on time
	hud.get_node("sub_title").text = "You didn't make it in time! The cat finally found you -- Cheddar's fate is unknown..."
	button.text = "Try again?"
	Global.print_text(hud.get_node("sub_title"))
	hud.show()

func reset_game():
	velocity = 2
	length = 40
	slot_num = 0
	part = 1
	slot = get_tree().get_nodes_in_group("slots")[slot_num]
	$moving_bar.position = Vector2(216, 14) ## Just the starting position.
	$countdown.text = str(length)
	$background.play("default")
	start_game()
		

func _on_won() -> void:
	$SFX.stream = load("res://assets/sounds/safe_open.wav")
	$SFX.play()
	$countdown/countdown_timer.stop()
	$second_part.hide()
	$background/contrast_screen.hide()
	$background.play("open")
	$countdown.hide()
	await get_tree().create_timer(2.5).timeout
	## Editing HUD to display win text.
	hud.get_node("title").text = 'YOU WIN!'
	hud.get_node("sub_title").text = "Cheddar scrambles inside the safe to find the house key!"
	button.text = "CONTINUE"
	Global.print_text(hud.get_node("sub_title"))
	hud.show()
	$background.play("open_no_key")

func _on_bar_shift_timer_timeout():
	var bar = get_tree().get_nodes_in_group("slots")[slot_num].get_node("green")
	bar.hide()
	bar.position.x = randf_range(30, 250)


func _on_next() -> void:
	$moving_bar.hide()
	$second_part.show()
	Global.print_text($second_part/text)
	part = 2
