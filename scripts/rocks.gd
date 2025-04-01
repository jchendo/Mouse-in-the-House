extends Area2D


# Called when the node enters the scene tree for the first time.
signal hit

func _on_body_entered(body: Node2D) -> void:
	if body is not StaticBody2D:
		hit.emit()
