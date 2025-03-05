extends Node2D

var mice
var fade
var black_screen = preload("res://scenes/black_screen_fade.tscn")
var cat_speed = 50
signal cutscene_over
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mice = get_tree().get_nodes_in_group("mice") ## Constantly update group in case of removal.
	if get_tree().get_nodes_in_group("mice").is_empty():
		## Fade to black, bring title screen in
		var fade = black_screen.instantiate()
		fade.connect("faded", _on_faded)
		add_child(fade)
		cutscene_over.emit()
		set_process(false)
	
	$Cat.position.x += cat_speed * delta

func _on_cat_hiss_timer_timeout() -> void:
	## Play hiss sound effect.
	$RunTimer.start() ## 2 seconds of jumping before the mice run
	$Cat/Hiss.play()
	for mouse in mice:
		mouse.play("jump")
		## Show exclamation points & set their size to default.
		$LargeTextBubble.show()


func _on_run_timer_timeout() -> void:
	## Mice run towards door.
	$LargeTextBubble.hide()
	cat_speed = 0
	$Cat.play("sleep")
	for mouse in mice:
		mouse.running = true

func _on_faded():
	queue_free()


func _on_cutscene_skip() -> void:
	cutscene_over.emit()
	queue_free()
