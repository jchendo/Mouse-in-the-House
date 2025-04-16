extends Area2D

@onready var interactable: Area2D = $interactArea

@export var obj_type = ""
@export var item = ""
@export var text_box = ""

func _ready() :
	pass
	

#When the interact signal is emitted from Cheddar,
func _on_cheddar_interact() -> void:
	pass
