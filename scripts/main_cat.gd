extends Area2D

signal player_hit
@onready var cheddar : CharacterBody2D = $".."/Cheddar
var started
var can_chase = true
var chase_started = false
var chasing = false
var speed = 30
var dest = 0
var set_dest = false
var can_see = 1 ## 0 if to the left, 1 if to the right
var end_game
var velocity = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO
	if started:
		var dist = position.x - cheddar.position.x
		if end_game:
			$Cat.play("run")
			set_dest = true
			dest = -110
			speed = 100
		elif dist <= 200 and dist >= 0 and can_see and can_chase:
			if cheddar.position.y > 330 and cheddar.is_on_floor():
				set_dest = false
				chasing = true
			elif cheddar.position.y < 330 and cheddar.is_on_floor():
				chasing = false
		elif dist >= -200 and dist <= 0 and not can_see and can_chase:
			if cheddar.position.y > 330 and cheddar.is_on_floor():
				set_dest = false
				chasing = true
			elif cheddar.position.y < 330 and cheddar.is_on_floor():
				chasing = false
		else:
			chasing = false
			chase_started = false
		if chasing:
			set_dest = false
			if not chase_started:
				chase_started = true
				$Cat.play("hiss")
				$Hiss.play()
				speed = 0
				await get_tree().create_timer(2.0).timeout
				$Cat.play("run")
				speed = 100
			else:
				if dist < -1:
					$Cat.flip_h = false
					velocity.x += speed * delta
				else:
					$Cat.flip_h = true
					velocity.x -= speed * delta
			if $Cat.animation != 'run' and $Cat.animation != "hiss":
				$Cat.play("run")
		else:
			if not set_dest:
				set_dest = true
				var rng = RandomNumberGenerator.new()
				dest = randf_range(65.0, 950.0)
				$Cat.play("walk")
				speed = 30
			else:
				if abs(dest - global_position.x) < 5:
					set_dest = false
				elif dest > global_position.x:
					velocity.x += speed * delta
					can_see = 0
					$Cat.flip_h = false
					can_see = false
				else:
					velocity.x -= speed * delta
					can_see = 1
					$Cat.flip_h = true
		
		position += velocity

func _on_body_entered(body: CharacterBody2D) -> void:
	if chasing:
		chase_started = false
		chasing = false
		can_chase = false
		player_hit.emit()
		$ChaseTimeout.start()

func set_destination():
	var rng = RandomNumberGenerator.new()
	dest = rng.randf_range(65.0, 950.0)
	set_dest = true


func _on_chase_timeout_timeout() -> void:
	can_chase = true
	
func play_anim(anim_name) -> void:
	if anim_name == "hide":
		hide()
	else:
		$Cat.play(anim_name)
