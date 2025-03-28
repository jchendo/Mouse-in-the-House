extends Node2D

var go = false
var go2 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mouse1.play("jump")
	$mouse2.play("jump")
	$mouse3.play("jump")
	$mouse4.play("jump")
	$mouse5.play("jump")
	$mouse6.play("jump")
	if go:
		$firework.play("shoot")
	if go2:
		$firework3.play("shoot")
	$firework2.play("shoot")


func _on_firework_timer_timeout() -> void:
	go = true


func _on_second_firework_timeout() -> void:
	go2 = true
