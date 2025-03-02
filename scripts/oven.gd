extends StaticBody2D

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.is_alive = true
	$Cheddar/Camera2D.zoom = Vector2(0.9, 0.9)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func restart_oven_game() -> void:
	$Cheddar.show()
