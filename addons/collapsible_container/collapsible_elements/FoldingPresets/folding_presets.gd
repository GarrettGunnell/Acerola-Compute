@tool
extends Control

## A Custom Control node placed inside the inspector of [CollapsibleContainer].
## Allows for selecting various FoldingPresets which change the 
## [member CollapsibleContainer.sizing_constraint] and its container sizing flags.
## [br]
## [br]The buttons fade out if they cannot be used (i.e., if the required 
## parent container is not there). 
## [br][br]The TIPS button remind the user that a container parent is required 
## to access some buttons.
## [br]
## [br]
## Placed in inspector through: collapsible_container_inspector_plugin.gd
## [br][br]Utilizes the [member CollapsibleContainer._editor_plugin] in [CollapsibleContainer] for
## undo-redo functionality. 

# REMINDER: if the buttons aren't changing colors properly, it may be because 
# the inspector is updating too soon.

enum ButtonStates {NORMAL, HOVERED, PRESSED}

@export var value_label : Label

@export_group("Buttons")
@export_subgroup("Main")
@export var top_left : TextureButton
@export var top_center : TextureButton
@export var top_right : TextureButton
@export var center_left : TextureButton
@export var center : TextureButton
@export var center_right : TextureButton
@export var bottom_left : TextureButton
@export var bottom_center : TextureButton
@export var bottom_right : TextureButton
@export var full_rect : TextureButton
@export_subgroup("HWide")
@export var h_top_wide : TextureButton
@export var h_center_wide : TextureButton
@export var h_bottom_wide : TextureButton
@export_subgroup("VWide")
@export var v_top_wide : TextureButton
@export var v_center_wide : TextureButton
@export var v_bottom_wide : TextureButton

@onready var currently_pressed_button = top_left

# Set by collapsible_container_inspector_plugin.gd
var collapsible : CollapsibleContainer


func _ready() -> void:
	# Avoid unnecessary error prints.
	if collapsible == null: 
		return
	
	if collapsible._in_game():
		return
	
	# If required container parent is not there, fade out some buttons.
	if not collapsible._has_parent_container():
		discourage_container_required_buttons()
	
	# Toggle button corresponding to whatever the current FoldingPreset is set to. 
	set_to_correct_button()
	
	# Connect all buttons to clicked().
	top_left.pressed.connect(clicked.bind(top_left))
	top_center.pressed.connect(clicked.bind(top_center))
	top_right.pressed.connect(clicked.bind(top_right))

	center_left.pressed.connect(clicked.bind(center_left))
	center.pressed.connect(clicked.bind(center))
	center_right.pressed.connect(clicked.bind(center_right))

	bottom_left.pressed.connect(clicked.bind(bottom_left))
	bottom_center.pressed.connect(clicked.bind(bottom_center))
	bottom_right.pressed.connect(clicked.bind(bottom_right))

	h_top_wide.pressed.connect(clicked.bind(h_top_wide))
	h_center_wide.pressed.connect(clicked.bind(h_center_wide))
	h_bottom_wide.pressed.connect(clicked.bind(h_bottom_wide))

	v_top_wide.pressed.connect(clicked.bind(v_top_wide))
	v_center_wide.pressed.connect(clicked.bind(v_center_wide))
	v_bottom_wide.pressed.connect(clicked.bind(v_bottom_wide))

	#full_rect.pressed.connect(clicked.bind(full_rect))

# Called on any inspector update (i.e., each time ready runs).
# Gets the current folding direction of the attached collapsible.
# Toggles the correct button based on the folding direction.
func set_to_correct_button() -> void:
	var direction : CollapsibleContainer.FoldingPreset = collapsible.get_folding_direction_preset()
	#print("Set color to: ", CollapsibleContainer.FoldingPreset.keys()[direction])
	
	value_label.set_text("")
	match direction:
		CollapsibleContainer.FoldingPreset.UNDEFINED:
			currently_pressed_button.set_pressed(false)
			value_label.set_text("UNDEFINED")
		CollapsibleContainer.FoldingPreset.PRESET_TOP_LEFT:
			change_color(top_left)
		CollapsibleContainer.FoldingPreset.PRESET_CENTER_TOP:
			change_color(top_center)
		CollapsibleContainer.FoldingPreset.PRESET_TOP_RIGHT:
			change_color(top_right)
		CollapsibleContainer.FoldingPreset.PRESET_CENTER_LEFT:
			change_color(center_left)
		CollapsibleContainer.FoldingPreset.PRESET_CENTER:
			change_color(center)
		CollapsibleContainer.FoldingPreset.PRESET_CENTER_RIGHT:
			change_color(center_right)
		CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_LEFT:
			change_color(bottom_left)
		CollapsibleContainer.FoldingPreset.PRESET_CENTER_BOTTOM:
			change_color(bottom_center)
		CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_RIGHT:
			change_color(bottom_right)
		CollapsibleContainer.FoldingPreset.PRESET_TOP_WIDE:
			change_color(h_top_wide)
		CollapsibleContainer.FoldingPreset.PRESET_HCENTER_WIDE:
			change_color(h_center_wide)
		CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_WIDE:
			change_color(h_bottom_wide)
		CollapsibleContainer.FoldingPreset.PRESET_LEFT_WIDE:
			change_color(v_top_wide)
		CollapsibleContainer.FoldingPreset.PRESET_VCENTER_WIDE:
			change_color(v_center_wide)
		CollapsibleContainer.FoldingPreset.PRESET_RIGHT_WIDE:
			change_color(v_bottom_wide)

# All buttons that require the collapsible to have a container parent in order 
# for the folding preset to work as intended... are faded.
func discourage_container_required_buttons() -> void:
	var container_required_buttons : Array[Node] = get_tree().get_nodes_in_group("container_required")
	for button in container_required_buttons:
		button.set_modulate(Color("ffffff40"))

# REMINDER: if the buttons aren't changing colors, it may be because the inspecor is updating too soon.
# Toggles the pressed button and untoggles the previously pressed button.
# Sets the appropriate folding_preset inside of CollapsibleContainer. 
func clicked(button : TextureButton) -> void:
	change_color(button)
	folding_preset_selected(button)

# The button in parameter is pressed. This changes it's texture to the 
# "pressed" texture, set in its inspector. Hence, changing its color.
# 
# Enables the previously pressed button and unpresses it (un-toggled).
# Disables the current button sets it to pressed (toggled).
func change_color(button : TextureButton) -> void:
	currently_pressed_button.button_pressed = false
	currently_pressed_button.disabled = false
	
	currently_pressed_button = button
	button.disabled = true

# Uses EditorUndoRedoManager to set the collapsible's folding_direction_preset variable.
func set_folding_preset(preset : CollapsibleContainer.FoldingPreset) -> void:
	var editor_undo_redot : EditorUndoRedoManager = collapsible._editor_plugin.get_undo_redo()
	
	editor_undo_redot.create_action("changed folding_direction_preset")
	editor_undo_redot.add_undo_property(collapsible, "folding_direction_preset", collapsible._folding_direction_preset)
	editor_undo_redot.add_do_property(collapsible, "folding_direction_preset", preset)
	editor_undo_redot.commit_action(true)

# calls set_folding_preset() with the correct parameter. 
func folding_preset_selected(button : TextureButton) -> void:
	match currently_pressed_button:
		top_left:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_TOP_LEFT)
		top_center:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER_TOP)
		top_right:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_TOP_RIGHT)
		##
		center_left:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER_LEFT)
		center:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER)
		center_right:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER_RIGHT)
		##
		bottom_left:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_LEFT)
		bottom_center:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER_BOTTOM)
		bottom_right:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_RIGHT)
#		full_rect:
#			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_CENTER)
		##
		h_top_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_TOP_WIDE)
		h_center_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_HCENTER_WIDE)
		h_bottom_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_BOTTOM_WIDE)
		v_top_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_LEFT_WIDE)
		v_center_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_VCENTER_WIDE)
		v_bottom_wide:
			set_folding_preset(CollapsibleContainer.FoldingPreset.PRESET_RIGHT_WIDE)

# Called when full_rect button is pressed. 
# Future: this button should probably be re-labelled as the "TIPS" button.
func _on_full_rect_pressed() -> void:
	print(full_rect.get_tooltip())
