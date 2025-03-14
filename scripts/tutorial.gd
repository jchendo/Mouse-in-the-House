extends Node2D

var text_num = 1
var inputs = [] ## to check if they've pressed all movement options
signal tutorial_finished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if text_num == 4:
		if Input.is_action_just_pressed("pick_up_item") and abs(150-$"Tutorial Cheddar".position.x) <= 45:
			$CarStart.play()
			tutorial_finished.emit()


func _on_text_timer_timeout() -> void:
	if text_num == 1:
		$"Tutorial Guide/Text1".visible_characters += 1
		if $"Tutorial Guide/Text1".visible_ratio == 1:
			await get_tree().create_timer(1.0).timeout
			$"Tutorial Guide/Text1".hide()
			text_num += 1
	elif text_num == 2:
		$"Tutorial Guide/Text2".visible_characters += 1
	elif text_num == 3:
		$"Tutorial Guide/Text2".hide()
		$"Tutorial Guide/Text3".visible_characters += 1
		if $"Tutorial Guide/Text3".visible_ratio == 1:
			text_num += 1


func _on_inputs_finished() -> void:
	if text_num == 2:
		text_num+=1
