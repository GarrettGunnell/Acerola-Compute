extends Control

## Decides if only 1 collapsible in the menu can be opened at a time or more.
@export var check_button : CheckButton

@export var collapsible_buttons : Array[Button]

#@export_group("collapsible buttons")
#@export var collapsible_button_1 : Button 
#@export var collapsible_button_2 : Button 
#@export var collapsible_button_3 : Button 
#
#@export_group("collapsible containers")
#@export var collapsible_1 : CollapsibleContainer
#@export var collapsible_2 : CollapsibleContainer
#@export var collapsible_3 : CollapsibleContainer

## Used when check_button is toggled to store the most recent button. 
## Which will be the 1 that remains opened while the other are closed.
var most_recent_button : Button

## Connects collapsible button's pressed signals to the _pressed() function.
func _ready() -> void:
	for collapsible_button in collapsible_buttons:
		collapsible_button.pressed.connect(_pressed.bind(collapsible_button))

## Opens the CollapsibleContainer corresponding to the button passes at the
## parameter. Closes all others if check_button is toggled. 
func open_tween(button : Button) -> void:
	if check_button.button_pressed:
		close_all_except(button)
	
	for collapsible_button in collapsible_buttons:
		if button == collapsible_button:
			collapsible_button.collapsible_node.open_tween_toggle()
			return

## Closes all CollapsibleContainers except the one corresponding to the button
## passed as the parameter. 
func close_all_except(button : Button) -> void:
	for collapsible_button in collapsible_buttons:
		if button != collapsible_button:
			collapsible_button.collapsible_node.close_tween()

## If check_button is toggled on, closes all but the most recent.
func _on_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		close_all_except(most_recent_button)

## Sets the most recent pressed and calls open_tween, which handles
## closing all others except most recent if necessary. 
func _pressed(button : Button) -> void:
	most_recent_button = button
	open_tween(button)
