extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cheddar/Camera2D.enabled = false
	$Cheddar.can_move = false
	#$Camera2D.global_position = Vector2(480, 180) # for testing purposes within oven_cutscene
	$Camera2D.global_position = Vector2(550, 217) # for main scene
	$Camera2D.zoom = Vector2(8,8)
	Global.in_oven_minigame = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print("fin")
	queue_free()
	
func play_anim(anim_name) -> void:
	if anim_name == "hideP1":
		$PaperMoveable1.hide()
	elif anim_name == "hideP2":
		$PaperMoveable2.hide()
	elif anim_name == "hide_speech":
		$Exclamation.hide()
		$SpeechBubble.hide()
	elif anim_name == "show_speech":
		$Exclamation.show()
		$SpeechBubble.show()
