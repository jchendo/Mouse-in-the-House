extends Node2D

#Cheddar variable
@onready var cheddar: CharacterBody2D = $"../Cheddar"

#Get list of interactable items in the tree on ready
var interactables
func _ready() -> void:
	interactables = get_tree().get_nodes_in_group("interactables2")

#Handle interactable items when 'E' is pressed
func _on_cheddar_interact() -> void:
	#print("signal recieved")
	var pos = cheddar.global_position
	#Placeholder global position
	var item_pos = cheddar.global_position
	#Set the selected item equal to the first item in the tree
	var selected_item = interactables[0]
	
	#Loop through every interactable item in the scene
	for item in interactables:
		#print(item)

		#*************FIND A WAY TO MAKE THE TOP ONES OPEN BETTER*****************
		#Find the closest interactable object and set it equal to selected_item
		if item.global_position.distance_to(pos) < selected_item.global_position.distance_to(pos):
			item_pos = item.global_position
			selected_item = item
			#print("set item_pos")
	#print("Selected item: ")
	#print(selected_item)
	if selected_item.name == "toaster":
		$toaster/AnimatedSprite2D.play("toast")
		cheddar.velocity.y = -350
		return
	
	#Execute animation of selected_item and add to globals for Cheddar.gd IF it isn't already open
	var anim = selected_item.get_node("AnimatedSprite2D")
	if anim.animation != "open":
		#print("anim is not open")
		anim.play("open")
		#Add to global_interactables group so Cheddar.gd can reference it
		selected_item.add_to_group("global_interactable")
		#print("changed label")
		var this_area = selected_item.get_node("interactArea")
		this_area.opened = ""


#Function for handling objects being pushed
func _on_cheddar_push() -> void:
	
	#Check for trash box movement
	if $trash/box.global_position.x <= 323:
		#print($trash/box.global_position.y)
		if $trash/box.global_position.y >= 375:
			$trash/StaticBody2D/trash_can.play("open")
			cheddar.velocity.y = -500
			cheddar.velocity.x = 250
			#print("we made it to trash box spot ")
