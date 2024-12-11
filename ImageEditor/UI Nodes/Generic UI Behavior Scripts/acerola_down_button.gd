extends Button

@export var root : Node

func _ready():
	pressed.connect(self._button_pressed)

func _button_pressed():
	var current_index = root.get_index()

	if current_index == root.get_parent().get_child_count(): return

	root.get_parent().move_child(root, current_index + 1)
