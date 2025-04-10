extends Area2D

signal hit


func _physics_process(delta):
	$AnimatedSprite2D.play("fly")
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		hit.emit()
