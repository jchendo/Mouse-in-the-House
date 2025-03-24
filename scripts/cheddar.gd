extends CharacterBody2D


const SPEED = 150.0
var JUMP_VELOCITY = -350.0

var is_picking_up_item = false
var is_using_item = false
var can_move = true
var running_minigame = false
var items_remaining = 5 ## temporary to make sure the oven minigame only happens once all items are picked up.
## hopefully do this better later
## its also a little glitchy -- if somebody opens the same cabinet/drawer more than once this var is still decreased

#Interactions variable
@export var all_interactions = []
signal interact

#Interaction pickups
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var item_sprite: Sprite2D = $Item_sprite
@onready var player_hud: Node2D = $"../HUD"
@export var item_picked_up: String
@onready var main: Node2D = $".."


#Interaction item variables
var kindling1 = preload("res://assets/sprites/ui/items/kindling1.png")
var kindling2 = preload("res://assets/sprites/ui/items/kindling2.png")
var kindling3 = preload("res://assets/sprites/ui/items/kindling3.png")
var kindling4 = preload("res://assets/sprites/ui/items/kindling4.png")
var kindling5 = preload("res://assets/sprites/ui/items/kindling5.png")


func _physics_process(delta: float) -> void:
	#item_sprite.hide()
	if can_move:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			$Jump.play()
			if $Walk.playing:
				$Walk.stop()
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("move_left", "move_right")
		
		if direction:
			if not $Walk.playing and is_on_floor():
				$Walk.play()
			velocity.x = direction * SPEED
			$AnimatedSprite2D.play("run")
			if direction < 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.play("idle")  # Play the idle animation if not moving
		
		# when to play jump and fall animation	
		if velocity.y > 0: 
			$AnimatedSprite2D.play("jump")
		if velocity.y < 0:
			$AnimatedSprite2D.play("fall")
		
		# when to play pick up/ use item animation
		if Input.is_action_pressed("pick_up_item"):
			is_picking_up_item = true
			#$AnimatedSprite2D.play("use_item")
		if Input.is_action_pressed("use_item"):
			is_using_item = true
			$AnimatedSprite2D.play("use_item") 
		
		# if not playing pick up/ use item animation go back to run/ idle
		if is_picking_up_item or is_using_item and not $AnimatedSprite2D.is_playing():
			is_using_item = false
			is_picking_up_item = false
		
		if running_minigame:
			velocity.x += SPEED
		
		move_and_slide()
		
		#Execute Interactions when E is pressed
		if Input.is_action_just_pressed("pick_up_item"):
			execute_interaction()


#Interaction Methods
########################################
func _on_interaction_area_entered(area: Area2D) -> void:
	all_interactions.insert(0, area)
	update_interactions()

#Remove from array when the area is exited
func _on_interaction_area_exited(area: Area2D) -> void:
	all_interactions.erase(area)
	update_interactions()

#Change interact label
func update_interactions():
	pass
	#if all_interactions:
		#interactLabel.text = all_interactions[0].interact_label
	#else:
		#interactLabel.text = ""

#Execute interaction when E is pressed
func execute_interaction():
	#If we are near an interaction spot
	if all_interactions:
		#print(all_interactions[0])
		interact.emit()

		#ANIMATION play code
		animated_sprite_2d.play("use_item")
		animation_player.play("item")
	
	#Call match_item on every member of the global_interactable group
		var curr_interaction = get_tree().get_nodes_in_group("global_interactable")
		var this_obj = curr_interaction[0]
	#print("this_obj:   ")
	#print(this_obj)
	
	#Change the texture that's shown in the animation_player based on which item is being picked up. Change the texture of the corresponding item in the inventory bar.
		match this_obj.item:
			"kindling1":
				item_sprite.texture = kindling1
				player_hud.get_node("OutlinePage").texture = kindling1
			"kindling2":
				item_sprite.texture = kindling2
				player_hud.get_node("OutlinePage2").texture = kindling2
			"kindling3":
				item_sprite.texture = kindling3
				player_hud.get_node("OutlinePage3").texture = kindling3
			"kindling4":
				item_sprite.texture = kindling4
				player_hud.get_node("OutlineOpenEnvelope").texture = kindling4
			"kindling5":
				item_sprite.texture = kindling5
				player_hud.get_node("OutlineClosedEnvelope").texture = kindling5
			"paperclip":
				pass
			"fish":
				pass
		
		#Take the interactable node out of the global group

		this_obj.remove_from_group("global_interactable")
		main.play_sfx('interact')
		items_remaining-=1
