extends Node
# script to create global variables to use in other scripts write Global.variable_name

var flames_visible = 0 # count how many flames visible in oven scene
var is_alive = true # if cheddar is alive or not

## Types out text instead of printing it all at once.
## Prefer this usage for displaying text.
func print_text(text_box, wait_time=0.05):
	text_box.visible_ratio = 0
	while (text_box.visible_ratio < 1):
		text_box.visible_characters += 1
		await get_tree().create_timer(wait_time).timeout
