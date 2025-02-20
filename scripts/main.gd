extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMap.hide()
	$Cheddar.hide()
	$Cheddar/Camera2D.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_game_start() -> void:
	$StartScreen.hide()
	$TileMap.show()
	$Cheddar.show()
	$Cheddar/Camera2D.enabled = true
