extends Button

@export var root : Node

func _ready():
	pressed.connect(self._button_pressed)

func _button_pressed():
	root.queue_free()
