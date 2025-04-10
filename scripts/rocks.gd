extends Area2D


# Called when the node enters the scene tree for the first time.
signal hit

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		hit.emit()
