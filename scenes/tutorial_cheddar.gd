extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -200.0

var is_picking_up_item = false
var is_using_item = false
var can_move = true
var inputs = []
signal tutorial_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(inputs) >= 4: 
		tutorial_finished.emit()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if "jump" not in inputs:
			inputs.append("jump")
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
		if "right" not in inputs:
			inputs.append("right")
		$AnimatedSprite2D.play("run")
		if direction < 0:
			$AnimatedSprite2D.flip_h = true
			if "left" not in inputs:
				inputs.append("left")
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
		if "pick_up" not in inputs:
			inputs.append("pick_up")
		is_picking_up_item = true
		$AnimatedSprite2D.play("pick_up_item")
	if Input.is_action_pressed("use_item"):
		is_using_item = true
		$AnimatedSprite2D.play("use_item") 
	
	# if not playing pick up/ use item animation go back to run/ idle
	if is_picking_up_item or is_using_item and not $AnimatedSprite2D.is_playing():
		is_using_item = false
		is_picking_up_item = false
		
	move_and_slide()
