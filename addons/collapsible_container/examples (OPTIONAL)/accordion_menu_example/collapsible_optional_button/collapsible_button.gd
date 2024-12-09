@tool
@icon("collapsible_container_button.svg")
extends Button
#class_name CollapsibleButton

## Button designed to be used with the [url=https://github.com/ArshvirGoraya/Godot-Collapsible-Container]CollapsibleContainer[/url]
## plugin node. Has an arrow/symbol which can be tweened to rotate. When 
## connected to a CollapsibleContainer, the arrow can rotate as the 
## CollapsibleContainer opens/closes, synchronizing with it. 
## Both [method CollapsibleContainer.get_normalized_size_or_null] and
## the normalized value which gets passed from 
## [signal CollapsibleContainer.tweening_amount_changed] is used to rotate the
## arrow/symbol around in a synchronized way. 
## [br][br]
## Warning: Not included with the main CollapsibleContainer plugin as this node 
## is underdeveloped.

## Controls rotation of the arrow/symbol as it opens/closes.
@export var collapsible_node : CollapsibleContainer:
	set = set_collapsible_node

## Sets the rotation the arrow/symbol will be in when opened.
@export_range(-360.0, 360.0, 0.1, "degrees") var opened_rotation : float = 90.0:
	set(x):
		opened_rotation = x
		if Engine.is_editor_hint():
			if rotator != null: 
				rotator.set_rotation_degrees(opened_rotation)
				
				if preview_timer != null:
					preview_timer.start(0.5)
					await preview_timer.timeout
					rotator.set_rotation_degrees(closed_rotation)

## Sets the rotation the arrow/symbol will be in when closed.
@export_range(-360.0, 360.0, 0.1, "degrees") var closed_rotation : float = 0.0:
	set(x):
		closed_rotation = x
		if Engine.is_editor_hint():
			if rotator != null: 
				rotator.set_rotation_degrees(closed_rotation)

## The pivot from which the arrow/symbol will rotate around.
@export var rotator_pivot := Vector2(0, 0):
	set = pivot_offset_changed

## Determines the arrow/symbol position.
@export var rotator_position := Vector2(0, 0):
	set(x):
		rotator_position = x
		if rotator != null:
			rotator.set_position(rotator_position)

## Tweens the arrow/symbol towards the opened and closed rotations back and forth 
## to preview in the editor.
@export var constant_rotate_preview : bool = false:
	set(x):
		constant_rotate_preview = x
		if not constant_rotate_preview:
			rotator.set_rotation_degrees(closed_rotation)
			constant_rotation_preview_progress = 0.0
			constant_rotation_preview_reversing = false
		notify_property_list_changed()

## Speed at which [member constant_rotate_preview] Tweens the arrow/symbol.
@export var constant_rotate_preview_speed : float = 0.5

## Defines the text of the button. Can use BBCode.
@export_multiline var text_label : String = "":
	set(x):
		text_label = x
		if text_label_rtl != null:
			text_label_rtl.set_text(text_label)
			rtl_text_changed()

## Defines the symbol of the button. Can use BBCode.
@export_multiline var symbol_label : String = "":
	set(x):
		symbol_label = x
		if text_symbol_rtl != null:
			text_symbol_rtl.set_text(symbol_label)
			rtl_text_changed()

@onready var preview_timer : Timer = $OpenRotPreviewTimer # Timer for rotation preview.

@onready var rotator : Control = $MarginContainer/HBoxContainer/SymbolSize/Rotator
@onready var rotator_pivot_offset_gizmo : Marker2D = $MarginContainer/HBoxContainer/SymbolSize/Rotator/RotatorPivotOffsetGizmo

@onready var text_label_rtl : RichTextLabel = $MarginContainer/HBoxContainer/Text
@onready var text_symbol_rtl : RichTextLabel = $MarginContainer/HBoxContainer/SymbolSize/Rotator/Symbol

var constant_rotation_preview_progress : float = 0.0
var constant_rotation_preview_reversing : bool = false

#func _init() -> void:
#	theme_changed.connect(
#	func():
#		text_label_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
#		text_symbol_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
#		)

# Set up all variables.
func _ready() -> void:
	text_label = text_label
	symbol_label = symbol_label
	
	theme_changed.connect(
	func():
		text_label_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
		text_symbol_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
		
#		text_label_rtl.add_theme_color_override("default_color", get_theme_color("font_color"))
#		text_symbol_rtl.add_theme_color_override("default_color", get_theme_color("font_color"))
		
		#print ("theme changed")
		)

	
	text_label_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
	text_symbol_rtl.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
#	text_label_rtl.add_theme_color_override("default_color", get_theme_color("font_color"))
#	text_symbol_rtl.add_theme_color_override("default_color", get_theme_color("font_color"))
	
	
	#text_symbol_rtl.push_font_size(get_theme_font_size("font_size"))
 
	# runs rotator_position's setter function, which sets it position.
	rotator_position = rotator_position 
	
	# If collapsible_node starts opened, start this as opened too.
	if collapsible_node != null:
		if collapsible_node._can_preview(): # in editor
			if collapsible_node._preview_starts_opened:
				rotator.set_rotation_degrees(opened_rotation)
			else:
				rotator.set_rotation_degrees(closed_rotation)
		else: # in game
			if collapsible_node.starts_opened:
				rotator.set_rotation_degrees(opened_rotation)
			else:
				rotator.set_rotation_degrees(closed_rotation)
	
	# Set pivot of the rotator.
	if rotator != null:
		rotator.set_pivot_offset(rotator_pivot)
		rotator_pivot_offset_gizmo.set_position(rotator.get_pivot_offset())

# Handles rotation preview.
func _process(delta: float) -> void:
	if constant_rotate_preview and Engine.is_editor_hint():
		if not constant_rotation_preview_reversing:
			_set_to_normalized_rotation(constant_rotation_preview_progress)
		else:
			_set_to_normalized_rotation(constant_rotation_preview_progress, true)
		
		constant_rotation_preview_progress += constant_rotate_preview_speed * delta
		
		# Handles reversing rotation when end is reached.
		if constant_rotation_preview_progress >= 1.0 and not constant_rotation_preview_reversing:
			constant_rotation_preview_progress = 0.0
			constant_rotation_preview_reversing = true
		elif constant_rotation_preview_progress >= 1.0 and constant_rotation_preview_reversing:
			constant_rotation_preview_progress = 0.0
			constant_rotation_preview_reversing = false

func _get_configuration_warnings():
	if collapsible_node == null:
		return ["This node is intended to work with an CollapsibleContainer, but \
				no CollapsibleContainer is assigned in its inspector."]
	if not get_children().has(preview_timer):
		return ["You should not use this node! Instead, instance the collapsible_button scene!"]

## Runs when either the [member text_label_rtl] or [member text_symbol_rtl] change.
## Set's the text of this button to the same as the combined text of those two 
## (without the BBCode). 
## [br][br]
## [b]Warning:[/b] This function is likely underdeveloped as the font of 
## the two [RichTextLabel]'s may differ from the font of this button, leading 
## to sizing differences. This may result in the text overflowing from the button,
## or the button being too big for the text.
func rtl_text_changed() -> void:
	set_text(str(text_label_rtl.get_parsed_text() + text_symbol_rtl.get_parsed_text()))

## Changes the offset of the gizmo and the rotator.
func pivot_offset_changed(x : Vector2) -> void:
	rotator_pivot = x
	if rotator_pivot_offset_gizmo != null and rotator != null:
		rotator_pivot_offset_gizmo.set_position(rotator_pivot)
		rotator.set_pivot_offset(rotator_pivot)

## Connects relevant signals from the [CollapsibleContainer] to the 
## relevant functions of this node.
## [signal CollapsibleContainer.tweening_amount_changed] is connected to
## [method collapsible_tween_progress] and 
## [signal CollapsibleContainer.state_set] is connected to 
## [method collapsible_state_set].
func set_collapsible_node(collapsible : CollapsibleContainer) -> void:
	var previous_collapsible_node : CollapsibleContainer = collapsible_node
	if previous_collapsible_node != null:
		collapsible_node.tweening_amount_changed.disconnect(collapsible_tween_progress)
		collapsible_node.state_set.disconnect(collapsible_state_set)
	
	if collapsible != null:
		collapsible_node = collapsible
		
		collapsible_node.tweening_amount_changed.connect(collapsible_tween_progress)
		collapsible_node.state_set.connect(collapsible_state_set)
	
	collapsible_node = collapsible
	update_configuration_warnings()

## Closes the arrow/symbol or opens it depending on the state change of 
## the [member collapsible_node].
func collapsible_state_set(_state : CollapsibleContainer.OpenedStates, _prev : CollapsibleContainer.OpenedStates) -> void:
	if collapsible_node.is_opened():
		rotator.set_rotation_degrees(opened_rotation)
	elif collapsible_node.is_closed():
		rotator.set_rotation_degrees(closed_rotation)
	else:
		var normalized_progress = collapsible_node.get_normalized_size_or_null()
		if normalized_progress != null:
			_set_to_normalized_rotation(normalized_progress)

## Called each increment of the [member collapsible_node]'s tween. Rotates the
## arrow/symbol as the [member collapsible_node] tweens open/close.
func collapsible_tween_progress(_new_size : Vector2, normalized_progress : float, _time_left : float) -> void:
	var tween_state_enum = collapsible_node.TweenStates
	var reverse : bool = false
	match collapsible_node.get_tween_state():
		tween_state_enum.CLOSING, tween_state_enum.AUTO_TWEENING_CLOSE:
			reverse = true
		tween_state_enum.FORCE_TWEENING:
			# Get desired rotation using normalized progress value
			var normalized_progress_closed_open = collapsible_node.get_normalized_size_or_null()
			if normalized_progress_closed_open != null:
				normalized_progress = normalized_progress_closed_open
	
	_set_to_normalized_rotation(normalized_progress, reverse)

# Set the rotation of the arrow/symbol basted on a normalized value between
# 0 - 1. If 0, set to closed. If 1 set to opened. Unless revere parameter is true.
# In which case, it is the opposite. 
func _set_to_normalized_rotation(normalized_progress : float, reverse : bool = false) -> void:
	if not reverse:
		var rotation_range = opened_rotation - closed_rotation
		var rotation_value = closed_rotation + normalized_progress * rotation_range
		rotator.set_rotation_degrees(rotation_value)
	else:
		var rotation_range = closed_rotation - opened_rotation
		var rotation_value = opened_rotation + normalized_progress * rotation_range
		rotator.set_rotation_degrees(rotation_value)
