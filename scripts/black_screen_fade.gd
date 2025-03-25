extends Sprite2D

## A simple scene for a black screen fade, useful for scene/changes probably.
signal faded ## Emits when screen is fully dark.
var is_faded = false
var text = [] ## Sentences as list indices (helps with display)
var sentence_num = 0
var screen_hold_time = 0
var text_displayed = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self_modulate.a >= 1 and text_displayed:
		await get_tree().create_timer(screen_hold_time).timeout
		is_faded = true
		$Timer.stop()
		faded.emit()
		queue_free()

## increase alpha to create a black screen & add text (if applicable)
func _on_timer_timeout() -> void:
	self_modulate.a += 0.02
	if $Label.text != '':
		await get_tree().create_timer(1.0).timeout
		text_displayed = false
		screen_hold_time = 2
		if $Label.visible_ratio < 1:
			$Label.visible_characters += 1;
		elif len(text) > sentence_num + 1: ## i.e. there is still another sentence
			sentence_num += 1
			$Label.text = text[sentence_num]
			$Label.visible_ratio = 0
		else:
			text_displayed = true
	else:
		text_displayed = true
				
