extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -350.0

var is_picking_up_item = false
var is_using_item = false
	
#Interactions variable
@export var all_interactions = []
signal interact

func _physics_process(delta: float) -> void:
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
		if not is_picking_up_item and not is_using_item:
			$AnimatedSprite2D.play("idle")
	
	# when to play jump and fall animation	
	if velocity.y > 0: 
		$AnimatedSprite2D.play("jump")
	if velocity.y < 0:
		$AnimatedSprite2D.play("fall")
	
	# when to play pick up/ use item animation
	if Input.is_action_pressed("pick_up_item"):
		is_picking_up_item = true
		$AnimatedSprite2D.play("pick_up_item")
	if Input.is_action_pressed("use_item"):
		is_using_item = true
		$AnimatedSprite2D.play("use_item") 
	
	# if not playing pick up/ use item animation go back to run/ idle
	if is_picking_up_item and is_using_item and not $AnimatedSprite2D.is_playing():
		is_using_item = false
		is_picking_up_item = false
		if direction:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")
		
	move_and_slide()

	# if not playing pick up/ use item animation go back to run/ idle
	if is_picking_up_item and is_using_item and not $AnimatedSprite2D.is_playing():
		is_using_item = false
		is_picking_up_item = false
		if direction:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")
		
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
		print(all_interactions[0])
		interact.emit()
