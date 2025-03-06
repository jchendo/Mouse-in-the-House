extends Node2D

#Cycle through the openables group
#Pick whichever one is the closet
#that drawer.animation.play("open")

#Make an export variable and then make it = whatever
#match that drawer.item
@onready var cheddar: CharacterBody2D = $"../Cheddar"

#Get list of interactable items in the tree
var interactables
func _ready() -> void:
	interactables = get_tree().get_nodes_in_group("interactables2")

#Handle interactable items when 'E' is pressed
func _on_cheddar_interact() -> void:
	print("signal recieved")
	var pos = cheddar.global_position
	#Placeholder global position
	var item_pos = cheddar.global_position
	#Set the selected item equal to the first item in the tree
	var selected_item = interactables[0]
	
	#Loop through every interactable item in the scene
	for item in interactables:
		print(item)

		#*************FIND A WAY TO MAKE THE TOP ONES OPEN BETTER*****************
		#Find the closest interactable object and set it equal to selected_item
		if item.global_position.distance_to(pos) < selected_item.global_position.distance_to(pos):
			item_pos = item.global_position
			selected_item = item
			print("set item_pos")
	print("Selected item: ")
	print(selected_item)
	
	#Execute function of selected_item
	var anim = selected_item.get_node("AnimatedSprite2D")
	anim.play("open")
	
