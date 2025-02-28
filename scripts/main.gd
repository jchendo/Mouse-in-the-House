extends Node2D

var camera_pan
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$map.hide()
	$Cheddar.hide()
	$Cheddar/Camera2D.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Code for initial camera pan to oven.
	while camera_pan:
		await get_tree().create_timer(0.05).timeout
		$Cheddar/Camera2D.global_position.x -= 0.1
		if $Cheddar/Camera2D.global_position.x <= 750:
			camera_pan = false
			await get_tree().create_timer(2.0).timeout
			$Cheddar/Camera2D.global_position.x = 1000
			$Cheddar.show()


func _on_game_start() -> void:
	$StartScreen.hide()
	$map.show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar/Camera2D.enabled = true
	camera_pan = true
