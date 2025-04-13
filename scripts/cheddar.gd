extends CharacterBody2D


const SPEED = 150.0
const PUSH_FORCE = 100
var JUMP_VELOCITY = -225.0

var has_paperclip = false
var is_picking_up_item = false
var is_using_item = false
var can_move = true
var running_minigame = false
var direction = 0.0
var items_remaining = 0 ## temporary to make sure the oven minigame only happens once all items are picked up.
## hopefully do this better later
## its also a little glitchy -- if somebody opens the same cabinet/drawer more than once this var is still decreased

#Push objects signal
signal push

#Interactions variable
@export var all_interactions = []
signal interact

#Interaction pickups
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var item_sprite: Sprite2D = $AnimatedSprite2D/Item_sprite
@export var pickup_string = "Open [E]"

#INSERT ACTUAL CALL TO PLAYER HUD
@onready var player_hud: Node2D = $"../HUD/InventoryBar"
@export var item_picked_up: String
@onready var main: Node2D = $".."

#Interaction item variables
var kindling1 = preload("res://assets/sprites/ui/items/kindling1.png")
var kindling2 = preload("res://assets/sprites/ui/items/kindling2.png")
var kindling3 = preload("res://assets/sprites/ui/items/kindling3.png")
var kindling4 = preload("res://assets/sprites/ui/items/kindling4.png")
var kindling5 = preload("res://assets/sprites/ui/items/kindling5.png")
var paperclip = preload("res://assets/sprites/ui/items/paperclip.png")
@onready var hud: Node2D = $"../HUD"

func _ready() -> void:
	item_sprite.hide()

func _physics_process(delta: float) -> void:
	#item_sprite.hide()
	$AnimatedSprite2D/Pickup_label.text = pickup_string
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
		direction = Input.get_axis("move_left", "move_right")

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
				#print("stopping")
			if $AnimatedSprite2D.animation != "idle" and !(all_interactions and is_picking_up_item):
				$AnimatedSprite2D.play("idle")

		# when to play jump and fall animation
		if velocity.y > 0:
			$AnimatedSprite2D.play("jump")
		if velocity.y < 0:
			$AnimatedSprite2D.play("fall")

		# when to play pick up/ use item animation
		if Input.is_action_pressed("pick_up_item"):
			#is_picking_up_item = true
			#$AnimatedSprite2D.play("use_item")
			pass
		if Input.is_action_pressed("use_item"):
			is_using_item = true
			$AnimatedSprite2D.play("use_item")

		if running_minigame:
			velocity.x += SPEED

		move_and_slide()

		#Execute Interactions when E is pressed
		if Input.is_action_just_pressed("pick_up_item"):
			execute_interaction()
		
		#Handle pushing objects
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collision_obj = collision.get_collider()
			if collision_obj.is_in_group("push_objs") and abs(collision_obj.get_linear_velocity().x) < 18:
				collision_obj.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
				push.emit()

#Interaction Methods
########################################
func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Area2D:
		all_interactions.insert(0, area)
		pickup_string = area.opened
		update_interactions(area)
	else:
		print("idk")

#Remove from array when the area is exited
func _on_interaction_area_exited(area: Area2D) -> void:
	all_interactions.erase(area)
	pickup_string = area.opened
	update_interactions(area)

#Change interact label
func update_interactions(area):
	if all_interactions and !Global.in_oven_minigame:
		$AnimatedSprite2D/Pickup_label.show()
	else:
		$AnimatedSprite2D/Pickup_label.hide()

#Execute interaction when E is pressed
func execute_interaction():
	#If we are near an interaction spot
	#print("execute_interaction")
	if all_interactions:
		#Execute test_world function
		#print("if all_interactions")
		interact.emit()

		#Exit the function if the object has already been opened
		if get_tree().get_nodes_in_group("global_interactable").is_empty():
			#print(" the drawer has already been opened ")
			return

		#Get initiated interaction from test_world.gd
		var curr_interaction = get_tree().get_nodes_in_group("global_interactable")
		var this_obj = curr_interaction[0]
		#print("this_obj: ")
		#print(this_obj)

		#Stop Cheddar's movement
		velocity.x = move_toward(velocity.x, 0, SPEED)
		can_move = false
		#ANIMATION play code
		$AnimatedSprite2D.play("use_item")
		item_sprite.show()
		if $AnimatedSprite2D.flip_h == true:
			animation_player.stop()
			animation_player.play("item_left")
		else:
			animation_player.stop()
			animation_player.play("item_right")
		#print("Animation player : ")
		#print(animation_player.current_animation)

	#Change the texture that's shown in the animation_player based on which item is being picked up. Change the texture of the corresponding item in the inventory bar.
		match this_obj.item:
			"kindling1":
				item_sprite.texture = kindling1
				player_hud.get_node("OutlinePage").texture = kindling1
				hud.run_narrator(this_obj.text_box)
			"kindling2":
				item_sprite.texture = kindling2
				player_hud.get_node("OutlinePage2").texture = kindling2
				hud.run_narrator(this_obj.text_box)
			"kindling3":
				item_sprite.texture = kindling3
				player_hud.get_node("OutlinePage3").texture = kindling3
				hud.run_narrator(this_obj.text_box)
			"kindling4":
				item_sprite.texture = kindling4
				player_hud.get_node("OutlineOpenEnvelope").texture = kindling4
				hud.run_narrator(this_obj.text_box)
			"kindling5":
				item_sprite.texture = kindling5
				player_hud.get_node("OutlineClosedEnvelope").texture = kindling5
				hud.run_narrator(this_obj.text_box)
			"paperclip":
				item_sprite.texture = paperclip
				has_paperclip = true
				hud.run_narrator(this_obj.text_box)
				#No outline in the inventory bar
			"fish":
				pass

		#Decrease items remaining if the player found an item
		if this_obj.item != "paperclip" && this_obj.item != "fish":
			items_remaining-=1

		#Take the interactable node out of the global group
		this_obj.remove_from_group("global_interactable")
		main.play_sfx('interact')
		items_remaining-=1
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	item_sprite.hide()
	can_move = true

func collide():
	var cat : Area2D = main.get_node("main_cat")
	if cat.velocity.x > 0:
		velocity = Vector2(SPEED * 2, -350)
	else:
		velocity = Vector2(-SPEED * 2, -350)
