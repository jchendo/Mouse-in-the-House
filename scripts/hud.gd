extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func run_narrator(text):
	$narrator_box/Label.text = text
	$narrator_box/Label.visible_ratio = 0
	$narrator_box.play("up")
	$narrator_box.show()
	$narrator_box/Label.show()
	await get_tree().create_timer(1.0).timeout
	Global.print_text($narrator_box/Label, 0.03)
	$narrator_box/squeaks.play()
	$narrator_box/Timer.start()


func _on_timer_timeout() -> void:
	$narrator_box/squeaks.stop()
	await get_tree().create_timer(1.0).timeout
	$narrator_box.play("down")
	$narrator_box/Label.hide()
	await get_tree().create_timer(0.5).timeout
	$narrator_box.hide()
	
