extends Node2D

var velocity = 2 ## Moving bar speed.
var slot_offset = 30 ## how many pixels apart are slots
@onready var slot : ColorRect = $slot_1_bg
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $moving_bar.position.x < 15:
		velocity = -velocity
	elif $moving_bar.position.x > 270:
		velocity = -velocity
		
	if Input.is_action_just_pressed("lockpick"):
		if in_green():
			slot.queue_free()
			slot = get_tree().get_first_node_in_group("slots")
			$moving_bar.position.y += slot_offset
			velocity += 2
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
