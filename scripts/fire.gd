extends Area2D


# Called when the node enters the scene tree for the first time.
signal hit

func _physics_process(delta):
	$AnimatedSprite2D.play("burn")

func _on_body_entered(body: Node2D) -> void:
	if body is not StaticBody2D:
		hit.emit()
