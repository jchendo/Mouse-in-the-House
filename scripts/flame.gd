extends Area2D

var flame_timer : Timer
var hide_timer : Timer

@onready var flame_sprite = get_node("AnimatedSprite2D")

var is_visible = 1 # 1 = invisible, 2 = almost visible, 3 = visible

var time_visible : float
var time_almost_visible : float # warns player that flame will appear 
var time_invisible : float 
var time_wait : float # how long flame wait before starting intially
var time_hide = 2 # wait until burn animation finishes before hiding player

var player_to_hide = null  # Variable to hold reference to the player to hide later

var max_visible_flames = 5 # number of flames that can be visible at a time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flame_timer = $FlameTimer
	hide_timer = $HidePlayerTimer
	$AnimatedSprite2D.play("flame")
	hide() # flames start hidden
	time_visible = randf_range(1,2) # how long flames stay visible
	time_invisible = randf_range(2,4) # how long flames stay invisible
	time_almost_visible = randf_range(2,4) # how long player will get warned of harmful flames
	time_wait = randf_range(6,8)
	flame_timer.start(time_wait)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.is_alive:
		if is_visible == 1: # invisible
			hide()
		
		elif is_visible == 2: # warning
			show()
			flame_sprite.modulate = Color(1 ,1, 1, 0.4)
		
		elif is_visible == 3: # visible
			show()
			flame_sprite.modulate = Color(1 ,1, 1, 1)
	
	
	for body in get_overlapping_bodies(): # if player touch visible flame they lose
		if body.is_in_group("player") and is_visible == 3:
			Global.is_alive = false
			var animation_player = body.get_node("AnimatedSprite2D")
			animation_player.stop()
			animation_player.play("burned") # death animation start playing
			hide_timer.start(time_hide) # start timer for when animation will end
			body.can_move = false # stop player from moving when burn animation starts
			
			player_to_hide = body
			
	if Global.is_alive == false:
		is_visible = 1
		hide() # when game over hide flames

func _on_timer_timeout() -> void:		
	#print(Global.flames_visible)
	# when timer goes off flame changes from invisible, almost visible, and visible
	if Global.is_alive:
		if is_visible == 3: 
			is_visible = 1
			Global.flames_visible -= 1
			#print("hide")
			flame_timer.start(time_invisible) 	
		
		elif is_visible == 1:
			if Global.flames_visible < max_visible_flames:
				is_visible = 2
				Global.flames_visible += 1
				#print("almost")
				flame_timer.start(time_almost_visible)
			
		elif is_visible == 2 :
			is_visible = 3
			#print("show")
			flame_timer.start(time_visible)

func restart_oven_game() -> void:
	# reset flames for player to try again
	flame_timer.start(6)
	is_visible = 1
	Global.flames_visible = 0

	
func player_won() -> void:
	is_visible = 1
	hide() # when game won hide flames


func _on_oven_hud_won() -> void:
	pass # Replace with function body.


func _on_hide_player_timer_timeout() -> void: # hide Cheddar after burn animation ends and make him move again
	player_to_hide.hide()
	player_to_hide.can_move = true
