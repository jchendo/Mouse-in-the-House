extends Node2D

var camera_pan
var oven_minigame = preload("res://scenes/oven.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$map.hide()
	$Cheddar.hide()
	$HUD.hide()
	$Cheddar/Camera2D.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Handling HUD movement & limits.
	if $Cheddar.position.x <= 760 and $Cheddar.position.x >= 66:
		$HUD.position.x = $Cheddar.position.x
	elif $Cheddar.position.x > 760:
		$HUD.position.x = 759
	elif $Cheddar.position.x < 66:
		$HUD.position.x = 60
	## Code for initial camera pan to oven.
	while camera_pan:
		$Cheddar.can_move = false
		await get_tree().create_timer(0.1).timeout
		$Cheddar/Camera2D.global_position.x -= 0.05
		if $Cheddar/Camera2D.global_position.x <= 750:
			camera_pan = false
			await get_tree().create_timer(2.0).timeout
			$Cheddar/Camera2D.global_position.x = 1000
			$Cheddar.show()
			$Cheddar.can_move = true
			$HUD.show()
			
	if Input.is_action_just_pressed("pick_up_item"):
		if abs($Cheddar.position.x - 630) <= 50:
			## Oven minigame setup.
			var oven = oven_minigame.instantiate()
			$map.hide()
			$StaticBody2D.hide()
			$HUD.hide()
			$StaticBody2D/CollisionShape2D.disabled = true
			$Cheddar.position = Vector2(613, 387)
			$Cheddar/Camera2D.zoom = Vector2(3,3)
			$Cheddar/Camera2D.limit_left = 510
			$Cheddar/Camera2D.limit_right = 930
			oven.get_node("OvenHUD").connect("won", _on_oven_minigame_win)
			add_child(oven)


func _on_game_start() -> void:
	$StartScreen.hide()
	$map.show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar/Camera2D.enabled = true
	camera_pan = true
	
func _on_oven_minigame_win():
	$map.show()
	$StaticBody2D.show()
	$HUD.show()
	$StaticBody2D/CollisionShape2D.disabled = false
	$Cheddar.global_position = Vector2(734, 377)
	$Cheddar/Camera2D.limit_left = 0
	$Cheddar/Camera2D.limit_right = 1022
	$Cheddar/Camera2D.zoom = Vector2(4,4)
