extends TextureButton

@export var urn_collapsible : CollapsibleContainer

func urn_pressed() -> void:
	urn_collapsible.close() # Closes the urn to its custom_close_size.
	urn_collapsible.open_tween() # Tweens urn open to its custom_open_size.


