extends MenuButton

@export var effects_list : VBoxContainer

var colorCorrectionScene : PackedScene = preload("res://ImageEditor/UI Nodes/Color Correction/color_correction.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed(id: int) -> void:
	match id:
		0: create_effect_ui(colorCorrectionScene)

func create_effect_ui(effect: PackedScene):
	effects_list.add_child(effect.instantiate())
