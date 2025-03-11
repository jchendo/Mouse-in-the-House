extends Sprite2D

## A simple scene for a black screen fade, useful for scene/changes probably.
signal faded ## Emits when screen is fully dark.
var screen_hold_time = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self_modulate.a >= 1:
		await get_tree().create_timer(screen_hold_time).timeout
		$Timer.stop()
		faded.emit()
		queue_free()

## increase alpha to create a black screen
func _on_timer_timeout() -> void:
	self_modulate.a += 0.01
