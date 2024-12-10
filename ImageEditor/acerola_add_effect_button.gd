extends MenuButton

@export var effects_list : VBoxContainer

var colorCorrectionScene : PackedScene = preload("res://ImageEditor/UI Nodes/Color Correction/acerola_color_correction_ui_node.tscn")
var gammaCorrectionScene : PackedScene = preload("res://ImageEditor/UI Nodes/Gamma Correction/acerola_gamma_correction_ui_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed(id: int) -> void:
	match id:
		0: create_effect_ui(colorCorrectionScene)
		1: create_effect_ui(gammaCorrectionScene)

func create_effect_ui(effect: PackedScene):
	effects_list.add_child(effect.instantiate())
