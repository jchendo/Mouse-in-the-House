extends Node2D

var camera_pan
var oven_minigame = preload("res://scenes/oven.tscn")
var running_minigame = preload("res://scenes/runningMiniGame.tscn")
var completed_oven = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$map.hide()
	$Cheddar.hide()
	$HUD.hide()
	$Cheddar/Camera2D.enabled = false
	$Cheddar.can_move = false


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
		$Directions.show()
		await get_tree().create_timer(0.1).timeout
		$Cheddar/Camera2D.global_position.x -= 0.05
		if $Cheddar/Camera2D.global_position.x <= 750:
			camera_pan = false
			await get_tree().create_timer(2.0).timeout
			$Cheddar/Camera2D.global_position.x = 1000
			$Cheddar.show()
			$Cheddar.can_move = true
			$HUD.show()
			$Directions.hide()
			
			
	if Input.is_action_just_pressed("pick_up_item"):
		if abs($Cheddar.position.x - 630) <= 50 and not completed_oven and $Cheddar.items_remaining <= 0:
			## Oven minigame setup.
			var oven = oven_minigame.instantiate()
			$map.hide()
			$StaticBody2D.hide()
			$HUD.hide()
			$StaticBody2D/CollisionShape2D.disabled = true
			$Cheddar.position = Vector2(613, 410)
			$Cheddar/Camera2D.zoom = Vector2(3,3)
			$Cheddar/Camera2D.limit_left = 510
			$Cheddar/Camera2D.limit_bottom = 550
			$Cheddar/Camera2D.limit_right = 930
			oven.get_node("OvenHUD").connect("won", _on_oven_minigame_win)
			add_child(oven)
			
		elif abs($Cheddar.position.x - 910) <= 50 and completed_oven:
			## Running minigame setup.
			var running = running_minigame.instantiate()
			$PostOvenText.hide()
			$Cheddar.position = Vector2(300, 410)
			$Cheddar.scale = Vector2(3,3)
			$Cheddar/Camera2D.enabled = false
			$Cheddar.JUMP_VELOCITY = -500.0
			$Cheddar.running_minigame = true
			$map.hide()
			$StaticBody2D.hide()
			$HUD.hide()
			$StaticBody2D/CollisionShape2D.disabled = true
			for fire in get_tree().get_nodes_in_group("main_flames"):
				fire.hide()
			add_child(running)


func _on_game_start() -> void:
	$StartScreen.hide()
	$map.show()
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$Cheddar/Camera2D.global_position = Vector2(900, 370)
	$Cheddar/Camera2D.enabled = true
	camera_pan = true
	
func _on_oven_minigame_win():
	completed_oven = true
	$map.show()
	$StaticBody2D.show()
	$HUD.show()
	$StaticBody2D/CollisionShape2D.disabled = false
	$Cheddar.global_position = Vector2(734, 377)
	$Cheddar/Camera2D.limit_left = 0
	$Cheddar/Camera2D.limit_right = 1022
	$Cheddar/Camera2D.limit_bottom = 382
	$Cheddar/Camera2D.zoom = Vector2(4,4)
	$PostOvenText.show()
	for fire in get_tree().get_nodes_in_group("main_flames"):
		fire.show()
