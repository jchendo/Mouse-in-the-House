extends Sprite2D

## A simple scene for a black screen fade, useful for scene/changes probably.
signal faded ## Emits when screen is fully dark.
var is_faded = false
var reverse = false
var text = [] ## Sentences as list indices (helps with display)
var sentence_num = 0
var screen_hold_time = 2
var text_displayed = false
var wait_time = 0.05
var font_size = 16
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = wait_time
	self_modulate.a = 1 * int(reverse) ## 0 if reverse is false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self_modulate.a >= 1 and text_displayed and not reverse:
		await get_tree().create_timer(screen_hold_time).timeout
		is_faded = true
		$Timer.stop()
		faded.emit()
		queue_free()
	elif self_modulate.a < 0 and reverse:
		$Timer.stop()
		faded.emit()
		await get_tree().create_timer(3.0).timeout
		queue_free()
## increase alpha to create a black screen & add text (if applicable)
func _on_timer_timeout() -> void:
	$Timer.wait_time = 0.05
	if not reverse:
		self_modulate.a += 0.02
	elif text_displayed:
		self_modulate.a -= 0.02
	if text != []:
		if len(text) > sentence_num and $Label.visible_ratio == 1: ## i.e. there is still another sentence
			$Label.text = text[sentence_num]
			$Label.visible_ratio = 0
			Global.print_text($Label, wait_time, font_size)
			sentence_num += 1
		elif $Label.visible_ratio >= 1:
			text_displayed = true
	else:
		text_displayed = true
				
