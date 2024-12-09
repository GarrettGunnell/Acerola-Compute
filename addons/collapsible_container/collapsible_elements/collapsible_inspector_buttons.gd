extends EditorProperty

## Buttons which are added into the inspector through the 
## collapsible_container_inspector_plugin.gd script.
## These buttons allow opening/closing the selected CollapsibleContainer 
## through the inspector.

## Creates the object to be added into the inspector: a VBox with 2 buttons 
## in it: open and close.
func _init() -> void:
	var buttons_holder := VBoxContainer.new()
	var open_button := Button.new()
	var close_button := Button.new()
	
	open_button.set_text("open")
	close_button.set_text("close")
	
	## Pressed signal calls the _open_pressed() function.
	open_button.connect("pressed", _open_pressed)
	
	## Pressed signal calls the _close_pressed() function.
	close_button.connect("pressed", _close_pressed)
	
	## Add buttons to the VBox.
	buttons_holder.add_child(open_button)
	buttons_holder.add_child(close_button)
	
	## Add VBox.
	add_child(buttons_holder)

## Calls the _preview_button() method on the selected CollapsibleContainer.
func _open_pressed() -> void:
	get_edited_object()._preview_button(true)

## Calls the _preview_button() method on the selected CollapsibleContainer.
func _close_pressed() -> void:
	get_edited_object()._preview_button(false)
