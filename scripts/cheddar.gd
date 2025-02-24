extends CharacterBody2D


const SPEED = 75
const JUMP_VELOCITY = -330
var animation_playing


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")
		if visible == true:
			## This variable allows the jump animation to finish before the run starts again.
			animation_playing = true
			$Jump.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		if $Footsteps.playing == false and is_on_floor() and visible == true: 
			$Footsteps.play()
		if animation_playing == false:
			$AnimatedSprite2D.play("run")
		
		if direction < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.play("idle")
	move_and_slide()


func _on_jump_finished() -> void:
	animation_playing = false
