extends PanelContainer

@export var collapsibleContainer : CollapsibleContainer

var enabled = true;

var effect_name : Label

func _ready() -> void:
	effect_name = find_child("Label")

func _process(delta: float) -> void:
	if enabled:
		effect_name.label_settings.font_color = Color(1.0, 1.0, 1.0)
	else:
		effect_name.label_settings.font_color = Color(0.5, 0.5, 0.5)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			collapsibleContainer.open_tween_toggle()
			
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			enabled = !enabled
