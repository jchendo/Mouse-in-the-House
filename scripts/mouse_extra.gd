extends AnimatedSprite2D

@export var SPEED = 75
@export var animation_name = ''
@export var title_screen = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var colors = ["964B00", "D3D3D3"]
	#modulate = Color(colors[randi_range(0,1)])
	play(animation_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if title_screen:
		position.x += SPEED * delta
		if position.x >= get_viewport_rect().size.x + 30:
			queue_free()
