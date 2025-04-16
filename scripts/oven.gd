extends StaticBody2D

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.is_alive = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func restart_oven_game() -> void:
	var player = get_tree().get_nodes_in_group("player")
	player[0].show()


func _on_player_won() -> void:
	var player = get_tree().get_nodes_in_group("player")
	player[0].show()
	player[0].can_move = true
	queue_free()

func _on_oven_hud_back() -> void:
	var player = get_tree().get_nodes_in_group("player")
	player[0].show()
	player[0].can_move = true
	queue_free()
