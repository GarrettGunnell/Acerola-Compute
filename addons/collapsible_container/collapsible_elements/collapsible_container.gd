@tool
@icon("res://addons/collapsible_container/collapsible_elements/collapsible_container.svg")
class_name CollapsibleContainer
extends Control

## [url=https://github.com/ArshvirGoraya/Godot-Collapsible-Container]CollapsibleContainer[/url]:
## a control node capable of hiding and revealing its children by folding and unfolding.
## The folding can be done with or without tweening and can be 
## previewed in the editor.
##
## Like an [url=https://en.wikipedia.org/wiki/Accordion_(GUI)]accordion UI[/url]
## element, this node can "hide" or "reveal" content due to its
## [member Control.clip_contents] being set to true by default. Thus, this node's size 
## determines how much of its children control nodes are seen. By changing its 
## size, the node can mimic folding and unfolding behaviour. 
## [br]
## [br]The "open" and "close" sizes can be set (see, [member use_custom_open_size] 
## and [member use_custom_close_size]) in order to open and close the node to
## those sizes. Alternatively, a control node can be set as the 
## [member sizing_node] variable and its size is used as the "open" size instead.
## This node can  automatically detect [member sizing_node]'s size changes, 
## allowing it to always match its size and reveal the node fully.
## [br]
## [br][b]Direction of folding/unfolding: [/b]
## [member sizing_constraint] allows the [CollapsibleContainer] to fold/unfold only the 
## width, height, or both. The constraint can be combined with [member Control.LayoutPreset]
## as well as [member Control.size_flags_horizontal] and [member Control.size_flags_vertical] for 
## many folding/unfolding directions. It is important to understand that 
## [b]container sizing flags[/b] give much more control over the direction this
## node folds/unfolds. [member Control.LayoutPreset] will NOT give you full control of
## the direction of folding/unfolding. For more control it is recommended to 
## child this node to a [MarginContainer] so that [b]container sizing flags[/b] 
## are accessible. It should be noted that the parent Container should probably
## have the  same [member custom_minimum_size] as this node for the intended effect. 
## To ease the process of assigning all these variables, you can simply set 
## [member folding_direction_preset] to a [enum FoldingPreset] value. which will also
## warn you if the desired direction requires a parent Container or not.
## [br][br]If the CollapsibleContainer has a child, the position the child stays 
## in while the CollapsibleContainer folds/unfolds will be determined by the child's 
## [member Control.LayoutPreset].
## It is recommended to use [method Control.set_anchors_and_offsets_preset]
## instead of [method Control.set_anchors_preset] when setting the child's 
## [member Control.LayoutPreset] through code. Keep in mind that the child may 
## struggle to stay centered while the CollapsibleContainer is tweening
## depending on the child's layout preset. This may result in jittery child movement 
## for the duration of the tween depending on the child's layout preset.
## [br][br]Finally, you should call any sizing method (e.g., [method force_size], 
## [method open], [method close_tween], etc.) using [method Object.call_deferred] 
## if you attempt to call it [b]right after[/b] setting the [member Control.LayoutPreset], 
## [member Control.size_flags_horizontal], [member Control.size_flags_vertical]
## or [member sizing_constraint]. 
## [br]
## [br][b]Warning[/b]: using built-in methods relating to size such as  
## [method Control.set_size] or [method Control.set_custom_minimum_size] 
## is not recommended with this node and may break something. 
## Instead, a substantial amount of functions are available in this 
## node for your sizing needs. These methods include [method open], 
## [method close], [method open_tween], [method close_tween], 
## [method open_toggle] and [method open_tween_toggle]. You can also 
## force the node to any size using [method force_size] and [method force_tween]
## , which will emit the necessary signals unlike using built-in methods.
## [br]
## [br][b]Warning[/b]: Tweening happens using [method Tween.interpolate_value] 
## and delta time. This means tween duration may run slightly longer than
## you set the duration to. For example, tween may run for 0.71 seconds instead 
## of 0.7 seconds precisely. Keep this in mind if you need precise timing.
## [br]
## [br]Usage:
## [codeblock]
##func _ready() -> void:
##   var collapsible := CollapsibleContainer.new()
##
##   # Decide if you want the collapsible node to start opened or start closed.
##   collapsible.starts_opened = false # Will start closed.
##
##   # Create/get node you want to hide. Here, we just create a label node.
##   var label_node := Label.new()
##   label_node.set_text("This is an example!")
##   
##   # Add the node as a child to the collapsible. Now it can be hidden/revealed.
##   collapsible.add_child(label_node)
##
##   # Alternatively, you can get a node which is already in the scene tree,
##   # remove it from its current parent and child it to the collapsible.
##   #var already_created_node = get_node(...)
##   #already_created_node.get_parent().remove_child(already_created_node)
##   #collapsible.add_child(already_created_node)
##
##   # Add the collapsible to the scene tree.
##   add_child(collapsible)
##
##   # Alternatively, instead of simply adding the collapsible, you can parent the 
##   # collapsible to a Container to use more folding directions! 
##   # Should give the parent Container a minimum size of the "open" size
##   # for the intended effect. 
##   #var parent_container := MarginContainer.new()
##   #parent_container.add_child(collapsible)
##   #add_child(parent_container)
##
##   # Set the sizing_node or set the custom size values. 
##   # Here, we just set the label as the sizing_node. Now, the label's size will be 
##   # used as the size the collapsible sets itself to when opened. In other words,
##   # the label's size is set as CollapsibleContainer's "open" size.
##   collapsible.set_sizing_node_path(label_node.get_path())
##
##   # Alternatively, to use custom size values instead:   
##   #collapsible.use_custom_open_size = true 
##   #collapsible.use_custom_close_size = true 
##   #collapsible.custom_open_size = Vector2(x, y)
##   #collapsible.custom_close_size = Vector2(x, y)
##   
##   # Modify the folding direction. (Folds from the top left by default).
##   # Here, we set it so that it folds from the top and is wide (as wide as the
##   # x/horizontal value in the "open" size).
##   # Some FoldingPresets require this node to be childed to a parent Container 
##   # (a MarginContainer is recommended) with a minimum size the same as the "open"
##   # size.
##   # But PRESET_TOP_WIDE, PRESET_TOP_LEFT and PRESET_LEFT_WIDE do not need a 
##   # parent Container. 
##   collapsible.set_folding_direction_preset(CollapsibleContainer.FoldingPreset.PRESET_TOP_WIDE)
##   
##   # Set desired the tween settings. Can also set tween_transition_type and tween_ease_type.
##   collapsible.tween_duration_sec = 0.7
##   
##   # Call open_tween() to start the tween.
##   # Should use call_deferred() if attempting to call open_tween() right after
##   # setting the LayoutPreset/FoldingPreset, sizing_constraint or container size flags.
##   collapsible.call_deferred("open_tween")
## [/codeblock]
##
## @tutorial: https://youtu.be/o2qTSv0QmKA

## Emitted when [member _opened_state] is set to any of the values in the 
## [enum OpenedStates] enum. It lets you know the current and previous state.
signal state_set(current_state: CollapsibleContainer.OpenedStates, previous_state: CollapsibleContainer.OpenedStates)

# Does not emit if previous tween was an AUTO tween ([constant AUTO_TWEENING_OPEN] 
# or [constant AUTO_TWEENING_CLOSE]) and current tween is also AUTO 
# ([constant AUTO_TWEENING_OPEN] or [constant AUTO_TWEENING_CLOSE]) as this is 
# seen as a single AUTO tween.
## Emitted when tweening has started.
signal tween_started(current_tween_state: CollapsibleContainer.TweenStates)

## Emitted when tweening has completed (i.e., when [member _tween_state] is 
## set to [constant NOT_TWEENING])
signal tween_completed(previous_tween_state: CollapsibleContainer.TweenStates)

## Emitted during tweening.
## [br][b]normalized_progress[/b]: where 0.0 is no progress and 1.0 is complete.
## [br][b]time_left[/b]: time until the tween ends in seconds.
## [br][b]Note:[/b] unlike the other signals, this also emits in the editor and 
## not just in game. This allows other tool scripts to know how far the
## node has progressed when previewing in the editor.
signal tweening_amount_changed(current_size : Vector2, normalized_progress : float, time_left : float)

## Emitted when tweening is interrupted usually by a change in 
## [member _opened_state] or [member _tween_state].
## Gives all information of what tween was running and the current states.
signal tween_interrupted(
		previous_tween_state : CollapsibleContainer.TweenStates,
		current_tween_state : CollapsibleContainer.TweenStates,
		current_opened_state : CollapsibleContainer.OpenedStates)

## Options used by [member sizing_constraint].
enum SizingConstraintOptions {
	BOTH,  ## Change both width and height when (un)folding.
	ONLY_HEIGHT,  ## Change only width when (un)folding.
	ONLY_WIDTH,  ## Change only height when (un)folding.
}

# Option used by [member _preview_auto_update_size]
## Options used by [member auto_update_size] 
enum AutoUpdateSizeOptions {
	DISABLED,  ## Disables AUTO sizing.
	WITH_TWEEN,  ## Automatically tweens to the full open or full close size if the size changes.
	WITHOUT_TWEEN,  ## Automatically sets to the full open or full close size if the size changes.
}

## States used by [member _opened_state].
enum OpenedStates {
	OPENED,  ## Node is opened.
	CLOSED,  ## Node is closed.
	FORCE_SIZED,  ## Node sized to a forced value. See, [method force_size] or [method force_tween].
	UPDATING_OPENED,  ## Node is automatically setting to a new open size. Can precede [constant AUTO_TWEENING_OPEN] and [constant AUTO_TWEENING_CLOSE].
	NOT_FULLY_OPENED,  ## Node's size is not set to the full open size (e.g., when auto sizing is disabled).
	TWEENING,  ## Node is tweening.
}

## States used by [member _tween_state].
enum TweenStates {
	OPENING,  ## Node is tweening to the open size.
	CLOSING,  ## Node is tweening to the close size.
	FORCE_TWEENING,  ## Node is forcibly tweening to a size.
	AUTO_TWEENING_OPEN,  ## Node is AUTO tweening to the open size.
	AUTO_TWEENING_CLOSE,  ## Node is AUTO tweening to the close size.
	NOT_TWEENING,   ## Node is not tweening.
}

## States used by [member folding_direction_preset]
enum FoldingPreset {
	PRESET_TOP_LEFT, 
	PRESET_TOP_RIGHT,
	PRESET_BOTTOM_LEFT,
	
	PRESET_BOTTOM_RIGHT,
	PRESET_CENTER_LEFT,
	PRESET_CENTER_TOP,
	
	PRESET_CENTER_RIGHT,
	PRESET_CENTER_BOTTOM,
	PRESET_CENTER,
	
	PRESET_LEFT_WIDE,
	PRESET_TOP_WIDE,
	PRESET_RIGHT_WIDE,
	PRESET_BOTTOM_WIDE,
	
	PRESET_VCENTER_WIDE,
	PRESET_HCENTER_WIDE,
	
	UNDEFINED,
}

## Determines if starts opened/closed in game. 
@export var starts_opened := true

## Automatically sets [member Control.clip_contents] to true/false when node is 
## loaded in editor or in game.
@export var start_with_clip_contents : bool = true: 
		set = set_start_with_clip_contents, get = get_start_with_clip_contents

# Uses _folding_direction_preset as a private variable to avoid infinite recursion. 
## Sets the [member sizing_constraint], [member Control.size_flags_vertical] 
## and [member Control.size_flags_horizontal] in order to quickly set the 
## folding direction.
@export var folding_direction_preset := FoldingPreset.PRESET_TOP_LEFT:
	set(x):
		_folding_direction_preset = x
		set_folding_direction_preset(_folding_direction_preset)
	get:
		return _folding_direction_preset

## Controls which direction the collapsible can folds/unfold.
@export var sizing_constraint := SizingConstraintOptions.BOTH:
		set = set_sizing_constraint, get = get_sizing_constraint

# Separate from [member _preview_auto_update_size] which controls 
# preview auto sizing, not in-game auto sizing. 
## Option to update the size automatically to the opened size value or the 
## closed size value when they change. For example, if opened, and 
## open size changes, the node will size itself to that new open size.
## [br][br][b]Note[/b]: If already tweening and a new open size is detected,
## this will interrupt the current tween (with a warning) if the tween's 
## target size is different from the new, auto-detected size change.
@export var auto_update_size := AutoUpdateSizeOptions.WITHOUT_TWEEN:
		set = set_auto_update_size, get = get_auto_update_size

# Can't be of type Control until nodes can be nullable: 
# https://github.com/godotengine/godot/pull/76843
## Node whose size will be used to set the "open size." 
## Must point to a [Control] node or any that inherit from it. 
## An alternative to [member custom_open_size] and [member custom_close_size]
## [br][br][b]Note[/b]: ignored if using [member custom_open_size].
#@export var sizing_node : Control = null: set = set_sizing_node_path, get = get_sizing_node 
@export_node_path("Control") var sizing_node : NodePath: 
	set = set_sizing_node_path, get = get_sizing_node_path

# Replaced with collapsible_inspector_buttons.gd through the 
# collapsible_container_inspector_plugin.gd script.
# Type is arbitrary but required so gave smallest type.
# @export required or buttons will not appear in inspector.
# Value serves no other purpose (can be false or true). 
@export var __preview_buttons : bool

@export_group("Sizing")
## Enables using [member custom_open_size].
@export var use_custom_open_size := false: 
		set = set_use_custom_open_size, get = get_use_custom_open_size

# Appears in inspector if [member use_custom_open_size] is true.
## Used as an alternative to [member sizing_node]'s size to set the "open size."
@export var custom_open_size := Vector2(0,0): 
		set = set_custom_open_size, get = get_custom_open_size

## Enables using [member custom_open_size].
@export var use_custom_close_size := false: 
		set = set_use_custom_close_size, get = get_use_custom_close_size

# Appears in inspector if [member use_custom_close_size].
## Used as an alternative to the default [constant Vector2.ZERO] 
## to set the "close size."
@export var custom_close_size := Vector2(0, 0): 
		set = set_custom_close_size, get = get_custom_close_size

@export_group("Tween Settings", "tween_")
## If true: runs tween in [method Node._physics_process] instead of [method Node._process].
@export var tween_in_physics_process := false

## Sets the duration of the tween in seconds.
@export_range(0.1, 1.0, 0.01, "or_greater") var tween_duration_sec := 0.5

## Sets the tween's transition type.
@export var tween_transition_type := Tween.TRANS_SINE

## Sets the tween's ease type. Does nothing if 
## [member tween_transition_type] is set to [constant Tween.TRANS_LINEAR].
@export var tween_ease_type := Tween.EASE_OUT

@export_group("Preview", "_preview")
# Enables/disables opening/closing previewing in editor. If this is disabled, 
# the open and close buttons in the inspector do nothing.
@export var _preview_enabled := true: set = _set_preview_enabled

# In editor (not in game), determines if starts opened/closed.
@export var _preview_starts_opened := true

# Preview option (not in game) to update the size automatically to the opened 
# size value or the closed size value when they change. For example, if opened,
# and open size changes, the node will set itself to that new open size.
# [br]Separate from [member auto_update_size] which controls 
# in-game auto sizing, not preview auto sizing. 
# [br]Will interrupt the current tween (with a warning) if the tween's target size is 
# different from the auto-updated target size.
@export var _preview_auto_update_size := AutoUpdateSizeOptions.WITHOUT_TWEEN: 
		set = _set_preview_auto_update_size

# Enables/disabled tweening preview in editor.
@export var _preview_tweening := true: set = _set_preview_tweening

@export_group("Process")
# Sets [member Node.process_mode] to [constant Node.PROCESS_MODE_ALWAYS]
# in the editor. This is to avoid the inability to see previews when a parent
# node's process is disabled in the editor.
# [member starts_with_process_mode] will set the process_mode back to what you wish
# when the game starts.
@export var _preview_always_process_in_editor : bool = true:
	set(x):
		if _in_editor():
			_preview_always_process_in_editor = x
			if _preview_always_process_in_editor:
				process_mode = Node.PROCESS_MODE_ALWAYS
			else:
				process_mode = starts_with_process_mode

## Sets the [member Node.process_mode] when entering game. 
## Overwrites whatever [member Node.process_mode] is set by 
## [member _preview_always_process_in_editor] once in game.
@export var starts_with_process_mode : ProcessMode = PROCESS_MODE_INHERIT:
	set(x):
		starts_with_process_mode = x
		process_mode = starts_with_process_mode

## Can be gotten to know the current opened state (see, [enum OpenedStates]).
## [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _opened_state := OpenedStates.OPENED

## Can be gotten to know the current tween state (see, [enum TweenStates]).
## [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _tween_state := TweenStates.NOT_TWEENING

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# Can be gotten to know how much time has elapsed in the current tween.
# [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _tween_elapsed_time := 0.0

# Calculated inside of [member _increment_tween].
# Emitted on each [member _emit_tween_amount_changed]
# Used by [signal tweening_amount_changed]
var _tween_time_left := 0.0

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# Can be gotten in order to know what the initial size value was before tween.
# [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _tween_initial_value := Vector2.ZERO

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# Can be gotten in order to know the delta value used in 
# [method Tween.interpolate_value].
# [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _tween_delta_value := Vector2.ZERO

# Used with [method Tween.interpolate_value] inside [member _increment_tween].
# Can be gotten in order to know the size the tween is tweening towards.
# [br][br][b]Warning:[/b] Should NOT be set externally (may break something).
var _tween_final_value := Vector2.ZERO

# Using private variable with [member folding_direction_preset] to avoid 
# infinite recursion. [folding_direction_preset] sets flags and sizing_constraint,
# which, themselves set [_folding_direction_preset]. If they were to set 
# [folding_direction_preset] instead, there would be an infinite recursion. 
var _folding_direction_preset := FoldingPreset.PRESET_TOP_LEFT:
	set(x):
		if x != _folding_direction_preset:
			_folding_direction_preset = x
			
			# Only want to update here if actually is different. 
			# Otherwise, will lag.
			_update_inspector() 

# Added by collapsible_container_plugin_loader.gd
# Remove Type Hint or will throw error on exports.
var _editor_plugin #: EditorPlugin

# Connects [signal Control.resized] signal to a function that emits the
# [signal tweening_amount_changed] signal.
#
# Also sets the [member Control.clip_content] property determined by 
# [member start_with_clip_contents].
#
# Sets the [member Node.process_mode] to [member starts_with_process_mode]
# or [member _preview_always_process_in_editor] depending on if in game or in editor.
#
# Connects the [signal size_flags_changed] to [method folding_direction_preset]
# can stay updated.
# so that [member ]
func _init() -> void:
	editor_description = "
			A custom/plugin Control node capable of hiding and revealing its children by folding and unfolding.
			\nGive feedback at: https://github.com/ArshvirGoraya/Godot-Collapsible-Container"
	
	if _in_game():
		process_mode = starts_with_process_mode
	if _in_editor():
		if _preview_always_process_in_editor:
			process_mode = Node.PROCESS_MODE_ALWAYS
	
	minimum_size_changed.connect(_emit_tween_amount_changed)
	set_clip_contents(start_with_clip_contents)
	size_flags_changed.connect(_update_folding_direction)

# If starts_opened: open. If not starts_opened: close
# as determined by [member starts_opened] or [member _preview_starts_opened].
func _ready() -> void:
	# If starts_opened: open. If not starts_opened: close
	# Does/should not emit any signals. Just sets the appropriate states and size.
	# If size can't be acquired (i.e., [member sizing_node] is null), prints an error.
	var start_open_or_closed = func () -> void:
		if (_in_editor() and _preview_starts_opened) or (_in_game() and starts_opened):
			var target_size = get_opened_size_or_null()
			if target_size == null:
				_print_warning_in_game("can't start opened: sizing_node is null.")
			else: 
				_opened_state = OpenedStates.OPENED
				_tween_state = TweenStates.NOT_TWEENING
				_set_to_size(target_size)
		else: 
			var target_size = get_closed_size_or_null()
			if target_size == null:
				_print_warning_in_game("can't start closed: sizing_node is null.")
			else: 
				_opened_state = OpenedStates.CLOSED
				_tween_state = TweenStates.NOT_TWEENING
				_set_to_size(target_size)
	
	# Must use call_deferred or sizing_node is seen as null when it isn't.
	start_open_or_closed.call_deferred()

# Calls [method _increment_tween] when tweening if 
# [member tween_in_physics_process] is false.
func _process(delta: float) -> void:
	if not tween_in_physics_process and is_tweening():
		_increment_tween(delta)

# Calls [method _increment_tween] when tweening if 
# [member tween_in_physics_process] is true.
func _physics_process(delta: float) -> void:
	if tween_in_physics_process and is_tweening():
		_increment_tween(delta)

# Unsure about indentation levels in this function matching style guides:
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#indentation
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#format-multiline-statements-for-readability
# A warning that shows on the node in the editor's scene tree given that the 
# condition is true: if sizing_node is set to nothing and not using open or closed size.
func _get_configuration_warnings():
	if (
			sizing_node == NodePath("") 
			and (not use_custom_open_size or not use_custom_close_size)
	):
		return ["A sizing_node or the custom_open and custom_close values must \
				be assigned for CollapsibleContainer to open/close as intended. 
				In the inspector, please assign sizing_node (a Control or \
				anything that inherits from Control) or use the custom \
				open/close sizing options."]

# Allows reverting custom_open_size value to the [member sizing_node]'s full size 
# if there is a [member sizing_node] set.
func _property_can_revert(property: StringName):
	if property == "custom_open_size":
		return true

# Sets the revert/default value of the [member custom_open_size] to the 
# [member sizing_node]'s if it's set.
func _property_get_revert(property: StringName):
	if property == "custom_open_size":
		var target_node = get_sizing_node_or_null()
		if target_node != null:
			return (target_node as Control).get_size()
		return Vector2.ZERO

## Returns the current [member _opened_state] value.
func get_opened_state() -> OpenedStates:
	return _opened_state

## Returns the current [member _tween_state] value.
func get_tween_state() -> TweenStates:
	return _tween_state

## Returns the current [member sizing_node] value.
func get_sizing_node_path() -> NodePath:
	return sizing_node

# Ideally returns -> [Control.LayoutPreset, bool]
## Calculates and returns what the [member folding_direction_preset] is currently set to.
func get_folding_direction_preset() -> FoldingPreset:
	var folding_direction : FoldingPreset
	var sizing_constraint_match : bool = false
	
	var container_sizing_flags : Array[SizeFlags] = [get_v_size_flags(), get_h_size_flags()]
	
	match container_sizing_flags:
		# Tops
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_TOP_LEFT
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER_TOP
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_TOP_RIGHT
		
		# Centers
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_CENTER_LEFT
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_CENTER_RIGHT

		# Bottoms
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_LEFT
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_CENTER_BOTTOM
		[Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_RIGHT
		
		# Side Wides:
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_BEGIN]:
			folding_direction = FoldingPreset.PRESET_LEFT_WIDE
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_END]:
			folding_direction = FoldingPreset.PRESET_RIGHT_WIDE
		[Control.SIZE_SHRINK_BEGIN, Control.SIZE_EXPAND_FILL]: #, [Control.SIZE_EXPAND, Control.SIZE_EXPAND_FILL]: 
			folding_direction = FoldingPreset.PRESET_TOP_WIDE
		[Control.SIZE_SHRINK_END, Control.SIZE_EXPAND_FILL]:
			folding_direction = FoldingPreset.PRESET_BOTTOM_WIDE
		
		# Center Wides:
		[Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER]:
			folding_direction = FoldingPreset.PRESET_VCENTER_WIDE
		[Control.SIZE_SHRINK_CENTER, Control.SIZE_EXPAND_FILL]:
			folding_direction = FoldingPreset.PRESET_HCENTER_WIDE
#		_:
#			_print_warning_in_game_or_err_in_editor(str("cannot GET folding_direction_preset: unsupported sizing flags: ", container_sizing_flags))
#			pass
	
	# Check if sizing_constraint is matching. Set from false to true if it is.
	match folding_direction:
		FoldingPreset.PRESET_LEFT_WIDE, FoldingPreset.PRESET_RIGHT_WIDE, FoldingPreset.PRESET_VCENTER_WIDE:
			if sizing_constraint == SizingConstraintOptions.ONLY_WIDTH:
				sizing_constraint_match = true
		FoldingPreset.PRESET_TOP_WIDE, FoldingPreset.PRESET_BOTTOM_WIDE, FoldingPreset.PRESET_HCENTER_WIDE:
			if sizing_constraint == SizingConstraintOptions.ONLY_HEIGHT:
				sizing_constraint_match = true
		_:
			if sizing_constraint == SizingConstraintOptions.BOTH:
				sizing_constraint_match = true
	
	if not sizing_constraint_match:
		folding_direction = FoldingPreset.UNDEFINED
	
	return folding_direction

## Uses [enum FoldingPreset] to set the [member Control.size_flags_vertical] 
## and [member Control.size_flags_horizontal].
## For some folding presets a parent container may be required. In these cases,
## if called when there is no [Container] as a parent, it will print an error 
## and do nothing. 
## [br][br]Presets that [b]do not[/b] require a parent container: [constant PRESET_TOP_LEFT], 
## [constant PRESET_TOP_WIDE], [constant PRESET_LEFT_WIDE]
## [br][br][param change_sizing_constraint]: sets [member sizing_constraint] based on the direction.
## If the layout is filled in one direction, the [member sizing_constraint] will constrain 
## that direction. For example, if it is set to PRESET_LEFT_WIDE where the vertical
## is completely filled, [member sizing_constraint] is set to [constant ONLY_HEIGHT]. 
## Hence, only the needed direction will open/close.
func set_folding_direction_preset(direction : FoldingPreset, change_sizing_constraint : bool = true) -> void:
	if not is_node_ready():
		return
	
	if direction == FoldingPreset.UNDEFINED:
		return
	
	# If not parent container, return if selected direction requires a parent container.
	if not _has_parent_container():
		if (
			not direction == Control.PRESET_TOP_LEFT
			and not direction == Control.PRESET_TOP_WIDE
			and not direction == Control.PRESET_LEFT_WIDE
			):
			_print_warning_in_game_or_err_in_editor(str("cannot SET folding_direction_preset to ", FoldingPreset.keys()[direction] ,": parent is not Container"))
			return
	
	match direction:
		Control.PRESET_TOP_LEFT:
#			set_anchors_preset(Control.PRESET_TOP_LEFT)
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) #top
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER_TOP:
#			set_anchors_preset(Control.PRESET_CENTER_TOP)
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_TOP_RIGHT:
#			set_anchors_preset(Control.PRESET_TOP_RIGHT)
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_SHRINK_END) # right
		
		Control.PRESET_CENTER_LEFT:
#			set_anchors_preset(Control.PRESET_CENTER_LEFT)
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER, Control.PRESET_FULL_RECT:
#			set_anchors_preset(Control.PRESET_CENTER)
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_CENTER_RIGHT:
#			set_anchors_preset(Control.PRESET_CENTER_RIGHT)
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_SHRINK_END) # right
		
		Control.PRESET_BOTTOM_LEFT:
#			set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) #left
		Control.PRESET_CENTER_BOTTOM:
#			set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_BOTTOM_RIGHT:
#			set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_SHRINK_END) # right
		
		Control.PRESET_LEFT_WIDE:
#			set_anchors_preset(Control.PRESET_LEFT_WIDE)
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN) # left
		Control.PRESET_RIGHT_WIDE:
#			set_anchors_preset(Control.PRESET_RIGHT_WIDE)
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_END) # right
		Control.PRESET_TOP_WIDE:
#			set_anchors_preset(Control.PRESET_TOP_WIDE)
			set_v_size_flags(Control.SIZE_SHRINK_BEGIN) # top
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide
		Control.PRESET_BOTTOM_WIDE:
#			set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
			set_v_size_flags(Control.SIZE_SHRINK_END) # bottom
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide
			
		Control.PRESET_VCENTER_WIDE:
#			set_anchors_preset(Control.PRESET_VCENTER_WIDE)
			set_v_size_flags(Control.SIZE_EXPAND_FILL) # wide
			set_h_size_flags(Control.SIZE_SHRINK_CENTER) # center
		Control.PRESET_HCENTER_WIDE:
#			set_anchors_preset(Control.PRESET_HCENTER_WIDE)
			set_v_size_flags(Control.SIZE_SHRINK_CENTER) # center
			set_h_size_flags(Control.SIZE_EXPAND_FILL) # wide
		_:
			var vertical_flag : String = FoldingPreset.keys()[get_v_size_flags()]
			var horizontal_flag : String = FoldingPreset.keys()[get_h_size_flags()]
			_print_warning_in_game_or_err_in_editor(str("cannot SET folding_direction_preset: unsupported LayoutPreset: ", direction))
			return
	
	if change_sizing_constraint:
		match direction:
			Control.PRESET_LEFT_WIDE, Control.PRESET_RIGHT_WIDE, Control.PRESET_VCENTER_WIDE:
				sizing_constraint = SizingConstraintOptions.ONLY_WIDTH
			Control.PRESET_TOP_WIDE, Control.PRESET_BOTTOM_WIDE, Control.PRESET_HCENTER_WIDE:
				sizing_constraint = SizingConstraintOptions.ONLY_HEIGHT
			_:
				sizing_constraint = SizingConstraintOptions.BOTH

# When [setting_node] changes,
# sets the [member sizing_node]'s [tree_exiting] to [_sizing_node_exiting],
# and sets the [member sizing_node]'s [resized] to [_sizing_node_resized].
func _connect_sizing_node_signals(node_path : NodePath) -> void:
	if not is_node_ready():
		await ready
	
	if node_path != NodePath(""):
		var new_sizing_node = get_node(node_path)
		new_sizing_node.connect("tree_exiting", _sizing_node_exiting)
		new_sizing_node.connect("resized", _sizing_node_resized)

# Connects sizing_nodes resized signal to [method _auto_size_to_full].
# Connects its tree_exiting signal to [method _sizing_node_exiting]
# Disconnects previous sizing_node's signals.
# [br]Calls [method _update_inspector] to allow revert value of 
# custom_open_size to set to the new node's size.
## Set's the [member sizing_node]. Can auto resize if [member auto_update_size] is enabled.
func set_sizing_node_path(node_path : NodePath) -> void:
	if _in_editor() and not _can_preview():
		sizing_node = node_path
		return
	
	var previous_sizing_node = get_node_or_null(sizing_node)
	
	# Node just entered tree in-game:
	if not is_node_ready():
		_connect_sizing_node_signals(node_path)
	else:
		# Do nothing if the same node:
		if node_path == sizing_node:
			return
		else:
			# Disconnect previous sizing_nodes resized signal.
			if previous_sizing_node != null:
				# If resized is connected, likely that tree_exiting is also connected so no need to check that one.
				if previous_sizing_node.is_connected("resized", _sizing_node_resized):
					previous_sizing_node.disconnect("resized", _sizing_node_resized)
					previous_sizing_node.disconnect("tree_exiting", _sizing_node_exiting)
					pass
		
		# New node is set to nothing: 
		if node_path == NodePath(""):
			if not use_custom_open_size or not use_custom_close_size:
				# The following error emits even when the scene is changing.
				# opting to remove it for now. Should only emit when the sizing_node is unparented.
				#_print_warning_in_game_or_err_in_editor("No sizing node detected: may size incorrectly.")
				pass
		# New node is set to something:
		else: 
			# New Node is not set to a Control (will not set the sizing_node in this case)
			if not get_node(node_path) is Control:
				_print_warning_in_game_or_err_in_editor("sizing_node must be Control or inherit from Control.")
				return
			# NewNode is s control, connects its signals.
			else:
				# Connect new sizing_nodes resized signal.
				_connect_sizing_node_signals(node_path)
				
				# Set to full size!
				_auto_size_to_full.call_deferred()
	
	sizing_node = node_path
	update_configuration_warnings()
	_update_inspector()

# Should add return Control once the following is merged: 
# Ideally, can return a null even if have "-> Control".
# https://github.com/godotengine/godot/pull/76843
## Gets the [member sizing_node] if it exists or null if it doesn't.
func get_sizing_node_or_null(): #-> Control:
	if sizing_node == NodePath(""):
		return null
	else:
		return get_node(sizing_node)

# Should add return Vector2 once the following is merged: 
# Ideally, can return a null even if have "-> Vector2".
# https://github.com/godotengine/godot/pull/76843
## Gets the opened size Vector. This could be the [member sizing_node]'s
## size or the [member custom_open_size], depending on which one is used.
## Will return null if using sizing_node and sizing_node is not set to anything.
## Importantly, will take [member sizing_constraint] into consideration.
func get_opened_size_or_null(): #-> Vector2:
	if use_custom_open_size:
		return custom_open_size
	else:
		var target_node = get_sizing_node_or_null()
		if target_node != null:
			var full_size : Vector2 = (target_node as Control).get_size()
			var largest_size_vale = _get_largest_size_value()
			
			# Ensure size follows the sizing constraint.
			match sizing_constraint:
				SizingConstraintOptions.ONLY_WIDTH: # Leave height as is.
					full_size = Vector2(full_size.x, largest_size_vale.y)
				SizingConstraintOptions.ONLY_HEIGHT: # Leave width as is.
					full_size = Vector2(largest_size_vale.x, full_size.y)
			return full_size
		return null

# Should add return Vector2 once the following is merged: 
# Ideally, can return a null even if have "-> Vector2".
# https://github.com/godotengine/godot/pull/76843
## Gets the closed size Vector. This could the be the either [constant Vector2.ZERO]
## or the [member custom_close_size] if custom close is used. 
## Will return null if using [member sizing_node] and sizing_node is not set to anything.
## Importantly, will take [member sizing_constraint] into consideration.
func get_closed_size_or_null(): #-> Vector2:
	if use_custom_close_size:
		return custom_close_size
	else:
		var target_node = get_sizing_node_or_null()
		if target_node != null:
			var full_size := Vector2.ZERO
			match sizing_constraint:
				SizingConstraintOptions.ONLY_WIDTH: # Leave height as is.
					full_size = Vector2(full_size.x, _get_largest_size_value().y)
				SizingConstraintOptions.ONLY_HEIGHT: # Leave width as is.
					full_size = Vector2(_get_largest_size_value().x, full_size.y)
			return full_size
		return null

## Enables usage of [member custom_open_size]. Can auto resize if [member auto_update_size] is enabled.
func set_use_custom_open_size(use_custom : bool) -> void:
	use_custom_open_size = use_custom
	_auto_size_to_full.call_deferred()
	_update_inspector() # Update's inspector to show the [member custom_open_size] vector option.
	update_configuration_warnings()

## Enables usage of [member custom_close_size]. Can auto resize if [member auto_update_size] is enabled.
func set_use_custom_close_size(use_custom : bool) -> void:
	use_custom_close_size = use_custom
	_auto_size_to_full.call_deferred()
	_update_inspector() # Update's inspector to show the [member custom_close_size] vector option.
	update_configuration_warnings()

## Sets [member custom_open_size]. Can auto resize if [member auto_update_size] is enabled.
func set_custom_open_size(custom_open : Vector2) -> void:
	custom_open_size = custom_open
	_auto_size_to_full.call_deferred()

## Sets [member custom_close_size]. Can auto resize if [member auto_update_size] is enabled.
func set_custom_close_size(custom_close : Vector2) -> void:
	custom_close_size = custom_close
	_auto_size_to_full.call_deferred()

## Sets [member sizing_constraint]. Can auto resize if [member auto_update_size] is enabled.
## Also updates [member update_folding_direction]. 
func set_sizing_constraint(constraint_option : SizingConstraintOptions) -> void:
	if not is_node_ready(): # Just entered scene tree:
		sizing_constraint = constraint_option
		return
	
	sizing_constraint = constraint_option
	_update_folding_direction()
	
	_auto_size_to_full.call_deferred()

## Sets [member auto_update_size]. Can auto resize if [member auto_update_size] is enabled.
## [br]If disabled and tweening, will interrupt tweening and set [member _opened_state] to
## [constant NOT_FULLY_OPENED].
func set_auto_update_size(auto_size_option : AutoUpdateSizeOptions) -> void:
	auto_update_size = auto_size_option
	_auto_update_size_changed(auto_update_size)

## Force the size of the node to the desired amount.
## Sets [member _opened_state] to [constant FORCE_SIZED].
## Interrupts any tweening happening.
func force_size(target_size : Vector2) -> void:
	var previous_opened_state : OpenedStates = _opened_state
	_opened_state = OpenedStates.FORCE_SIZED
	if is_tweening():
		var previous_tween_state : TweenStates = _tween_state
		_tween_state = TweenStates.NOT_TWEENING
		_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
	
	_set_to_size(target_size)
	
	_emit_opened_state_signal(previous_opened_state, _opened_state)

## Forces a tween towards the desired size.
## [br]Sets [member _tween_state] to [constant FORCE_TWEENING].
## [br]Sets [member _opened_state] to [constant TWEENING].
## [br]Interrupts any tweening happening.
func force_tween(target_size : Vector2) -> void:
	var previous_opened_state : OpenedStates = _opened_state
	_opened_state = OpenedStates.TWEENING
	var previous_tween_state : TweenStates = _tween_state
	
	# Stop current tween and emit interrupted if necessary.
	if is_tweening():
		_tween_state = TweenStates.NOT_TWEENING
		_emit_tween_interrupted(previous_tween_state, TweenStates.FORCE_TWEENING, _opened_state)
	
	# Start force tween.
	_set_tween_variables(target_size)
	_tween_state = TweenStates.FORCE_TWEENING
	
	# Emit necessary signals.
	_emit_tween_started(_tween_state)
	_emit_opened_state_signal(previous_opened_state, _opened_state)

## Checks if tweening and if so, forces any tweens happening to stop.
## [br]Sets [member _opened_state] to [constant FORCE_SIZED].
## [br]Sets [member _tween_state] to [constant NOT_TWEENING].
func force_stop_tween() -> void:
	if is_tweening():
		var previous_opened_state : OpenedStates = _opened_state
		_opened_state = OpenedStates.FORCE_SIZED
		
		var previous_tween_state : TweenStates = _tween_state
		_tween_state = TweenStates.NOT_TWEENING
		
		_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
		_emit_opened_state_signal(previous_opened_state, _opened_state)

## If tweening, will set the size to the final tween value and emit the 
## appropriate signals.
## [br][br][b]Note:[/b] If the argument provided is false will emit the 
## [signal tween_completed] signal. Otherwise, will emit 
## [signal tween_interrupted].
func set_to_end_tween(interrupted_tween : bool =  true) -> void:
	if is_tweening():
		var previous_tween_state = _tween_state
		var previous_opened_state = _opened_state
		
		_opened_state = _get_target_opened_state(previous_tween_state)
		
		if _in_game() and interrupted_tween and is_tweening():
			_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
		elif _in_game() and not interrupted_tween:
			_emit_tween_completed(previous_tween_state)
		
		_tween_state = TweenStates.NOT_TWEENING
		
		_set_to_size(_tween_final_value)
		# Set appropriate opened_state: 
		_emit_opened_state_signal(previous_opened_state, _opened_state)
	else:
		_print_warning_in_game("attempt to call set_to_end_tween when no tween is playing.")

## Immediately opens to the opened size, which can be the size of the 
## [member sizing_node] or the [member custom_open_size].
func open() -> void:
	_change(true, false)

## Immediately closes to the closed size, which can be the size of 
## [constant Vector2.ZERO] or the [member custom_close_size].
func close() -> void:
	_change(false, false)

## Begins tweening towards the opened size, which can be the size of the 
## [member sizing_node] or the [member custom_open_size].
func open_tween() -> void:
	_change(true, true)

## Begins tweening towards closed size, which can be the size of
## [constant Vector2.ZERO] or the [member custom_close_size].
func close_tween() -> void:
	_change(false, true)

## If is already opened, will be set to close. Otherwise, will be set to open.
func open_toggle() -> void:
	if is_opened():
		close()
	else:
		open()

## If is already opened or opening, will begin closing. Otherwise, will begin opening.
func open_tween_toggle() -> void:
	if is_opened() or is_opening():
		close_tween()
	else:
		open_tween()

## Returns if [member _opened_state] is [constant OPENED].
func is_opened() -> bool:
	return _opened_state == OpenedStates.OPENED

## Returns if [member _opened_state] is [constant CLOSED].
func is_closed() -> bool:
	return _opened_state == OpenedStates.CLOSED

## Returns if [member _tween_state] is [constant OPENING].
func is_opening() -> bool:
	return _tween_state == TweenStates.OPENING

## Returns if [member _tween_state] is [constant CLOSING].
func is_closing() -> bool:
	return _tween_state == TweenStates.CLOSING

## Returns if [member _tween_state] is not [constant NOT_TWEENING]
func is_tweening() -> bool:
	return _tween_state != TweenStates.NOT_TWEENING

# Should add return float once the following is merged: 
# Ideally, can return a null even if have "-> float".
# https://github.com/godotengine/godot/pull/76843
## Returns a normalized version (0 - 1) of the current size value between 
## the opened size and closed size range, or null.
func get_normalized_size_or_null():# -> float:
	var closed_size = get_closed_size_or_null()
	var opened_size = get_opened_size_or_null()
	
	if opened_size == null:
		_print_warning_in_game_or_err_in_editor(
			"attempt to call get_normalized_size() but opened and closed size 
			return null. Likely that sizing_node is null.")
		return null
	
	var current_size : Vector2 = get_custom_minimum_size()
	var initial_size : Vector2 = closed_size
	var target_size : Vector2 = opened_size
	
	var current_distance: float = (current_size - initial_size).length()
	var total_distance: float = (target_size - initial_size).length()
	var normalized_progress : float = current_distance / total_distance
	return normalized_progress

## Returns [member use_custom_open_size]
func get_use_custom_open_size() -> bool:
	return use_custom_open_size

## Returns [member custom_open_size]
func get_custom_open_size() -> Vector2:
	return custom_open_size

## Returns [member use_custom_close_size]
func get_use_custom_close_size() -> bool:
	return use_custom_close_size

## Returns [member custom_close_size]
func get_custom_close_size() -> Vector2:
	return custom_close_size

## Returns [member sizing_constraint]
func get_sizing_constraint() -> SizingConstraintOptions:
	return sizing_constraint

## Returns [member auto_update_size]
func get_auto_update_size() -> AutoUpdateSizeOptions:
	return auto_update_size

## Returns [member start_with_clip_contents]
func get_start_with_clip_contents() -> bool:
	return start_with_clip_contents

## Returns [member tween_in_physics_process]
func get_tween_in_physics_process() -> bool:
	return tween_in_physics_process

## Returns [member tween_duration_sec]
func get_tween_duration_sec() -> float:
	return tween_duration_sec

## Returns [member tween_transition_type]
func get_tween_transition_type() -> Tween.TransitionType:
	return tween_transition_type

## Returns [member tween_ease_type]
func get_tween_ease_type() -> Tween.EaseType:
	return tween_ease_type

## Setter for [member starts_opened].
func set_starts_opened(opened : bool) -> void:
	starts_opened = opened

## Setter for [member start_with_clip_contents].
func set_start_with_clip_contents(start_clip : bool) -> void:
	start_with_clip_contents = start_clip

## Setter for [member tween_in_physics_process].
func set_tween_in_physics_process(in_physics : bool) -> void:
	tween_in_physics_process = in_physics

## Setter for [member tween_duration_sec].
func set_tween_duration_sec(tween_dur : float) -> void:
	tween_duration_sec = tween_dur

## Setter for [member tween_transition_type].
func set_tween_transition_type(transition_type : Tween.TransitionType) -> void:
	tween_transition_type = transition_type

## Setter for [member set_tween_ease_type].
func set_tween_ease_type(ease_type : Tween.EaseType) -> void:
	tween_ease_type = ease_type

# Main function used for opening/closing the node.
# Gets the target size (closed or opened size depending on parameter value). 
# Tweens towards it or set the size to it immediately (depending on parameter).
# Emits any necessary signals: [signal tween_started], 
# [signal opened_state_signal] and [signal tween_interrupted].
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _change(open: bool, tweening: bool) -> void:
	# Get closed or opened target size.
	var target_size = get_opened_size_or_null() if open else get_closed_size_or_null()
	
	# Handle error if sizing node is null
	if target_size == null:
		_print_warning_in_game_or_err_in_editor("can't open/close: sizing_node is null.")
		return
	
	# Do nothing if already opened/closed. Just emit the set signal.
	if ((open and _opened_state == OpenedStates.OPENED)
		or (not open and _opened_state == OpenedStates.CLOSED)):
		_emit_opened_state_signal(_opened_state, _opened_state)
		return
	
	var previous_opened_state : OpenedStates = _opened_state
	var previous_tween_state : TweenStates = _tween_state
	
	# Tween to open/close if tweening is enabled.
	if tweening:
		# If already tweening and final_value is the same as target_size, do nothing.
		if is_tweening() and (_tween_final_value == target_size):
			return
		
		_opened_state = OpenedStates.TWEENING
		var target_tween_state : TweenStates = TweenStates.OPENING if open else TweenStates.CLOSING
		
		# If already tweening, interrupt previous tween.
		if is_tweening():
			_tween_state = TweenStates.NOT_TWEENING
			_emit_tween_interrupted(previous_tween_state, target_tween_state, _opened_state)
			
		_set_tween_variables(target_size)
		_tween_state = target_tween_state
		
		# Start tween emit:
		_emit_tween_started(_tween_state)
		_emit_opened_state_signal(previous_opened_state, _opened_state)
	
	# Set to open or close.
	else:
		_opened_state = OpenedStates.OPENED if open else OpenedStates.CLOSED
		
		# If is tweening, interrupt and stop.
		if is_tweening():
			_tween_state = TweenStates.NOT_TWEENING
			_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
		
		# Set size and emit signal.
		_set_to_size(target_size)
		_emit_opened_state_signal(previous_opened_state, _opened_state)

# Automatically sizes the node to the current full size, which may be the open size
# or the close size, depending on which states ([member _opened_state] and 
# [member _tween_state]) are currently set.
# Useful only if [member _preview_auto_update_size] or [member auto_update_size]
# are not disabled. 
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _auto_size_to_full() -> void:
	if not is_node_ready():
		return
	
	var auto_size_value = _preview_auto_update_size if _in_editor() else auto_update_size
	
	# Only perform function if not disabled.
	if auto_size_value == AutoUpdateSizeOptions.DISABLED:
		return
	
	# Only do in editor if preview is enabled.
	if _in_editor() and not _can_preview():
		return
		
	# Get full size and what opened state will be after set to full size.
	var target_values = _get_full_size_or_null_and_target_opened()
	var full_size = target_values[0]
	var target_opened_state : OpenedStates = target_values[1] 
	
	# For signals:
	var previous_opened_state : OpenedStates = _opened_state
	var previous_tween_state : TweenStates = _tween_state
	
	# If sizing_node is null and using it to set the size.
	if full_size == null:
		_print_warning_in_game_and_editor("can't update size automatically: sizing_node is null.")
		return
	
	# If already at the full size, no need to continue.
	if full_size == get_size():
		return
	
	# If already tweening and the tween's target size is the same as full_size, 
	# simply continue tweening. Instead of auto tweening.
	# Otherwise, print a warning and then interrupt the tween with the auto tween.
	if (previous_tween_state == TweenStates.OPENING
		or previous_tween_state == TweenStates.CLOSING):
			if full_size == _tween_final_value:
				return
			else:
				_print_warning_in_game_and_editor(
					"NON-AUTO tween was interrupted by AUTO_SIZE: sizing_node changed size during a NON-AUTO_SIZE tween")
	
	# If previous tweening was not AUTO Tweening, then set _opened_state to UPDATING_OPENED and emit signal.
	# Do not want it to set to UPDATING_OPENED if was already AUTO tweening.
	# Repeated AUTO tweening should always be seen as a single AUTO tween.
	# Since sizing_node's resized events set to AUTO tween each time it emits.
	# Resized may happen multiple times in a row...
	if (previous_tween_state != TweenStates.AUTO_TWEENING_OPEN 
		and previous_tween_state != TweenStates.AUTO_TWEENING_CLOSE
	):
		_opened_state = OpenedStates.UPDATING_OPENED
		_emit_opened_state_signal(previous_opened_state, _opened_state)
	
	match auto_size_value:
		# Update without tween.
		AutoUpdateSizeOptions.WITHOUT_TWEEN:
			# Stop tweening if tweening. 
			_tween_state = TweenStates.NOT_TWEENING
			
			# Set to new _opened_state.
			previous_opened_state = _opened_state
			_opened_state = target_opened_state
			
			# Emit tween interrupted signal if necessary.  
			if previous_tween_state != TweenStates.NOT_TWEENING:
				_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
			
			# Sets to the full size.
			_set_to_size(full_size)
			
			# Emits necessary _opened_state signals.
			_emit_opened_state_signal(previous_opened_state, _opened_state)
		
		# Update with tween.
		AutoUpdateSizeOptions.WITH_TWEEN:
			# Get if AUTO_TWEENING_OPEN or AUTO_TWEENING_CLOSE.
			var target_tween_state = TweenStates.AUTO_TWEENING_OPEN \
				if target_opened_state == OpenedStates.OPENED \
				else TweenStates.AUTO_TWEENING_CLOSE
			
			# Set to new _opened_state.
			_opened_state = OpenedStates.TWEENING
			
			# Stop tweening and emit tween interrupted signal if necessary.  
			if previous_tween_state != TweenStates.NOT_TWEENING:
				_tween_state = TweenStates.NOT_TWEENING
				_emit_tween_interrupted(previous_tween_state, target_tween_state, _opened_state)
			
			# Set tween variables for upcoming AUTO tween.
			_set_tween_variables(full_size)
			
			# Set to new _tween_state.
			_tween_state = target_tween_state
			
			# Emit tween started signal.
			_emit_tween_started(_tween_state)
			
			# Emits necessary _opened_state signals.
			_emit_opened_state_signal(previous_opened_state, _opened_state)

# Called by [member set_auto_update_size] and [member _set_preview_auto_update_size].
# If disabled, sets states to correct values and stops any AUTO tweening.
func _auto_update_size_changed(auto_size_option : AutoUpdateSizeOptions) -> void:
	if auto_size_option == AutoUpdateSizeOptions.DISABLED:
		if (
			_tween_state == TweenStates.AUTO_TWEENING_OPEN 
			or _tween_state == TweenStates.AUTO_TWEENING_CLOSE
		):
			# If disabled, set to not tweening and set _opened_state to NOT_FULLY_OPENED
			# or set _opened_state to target_opened_state if sizes to the full size already.
			var target_values = _get_full_size_or_null_and_target_opened()
			var full_size = target_values[0]
			var target_opened_state : OpenedStates = target_values[1] 
			var previous_opened_state : OpenedStates = _opened_state
			var previous_tween_state : TweenStates = _tween_state
			
			if full_size == null: 
				_print_warning_in_game_and_editor("can't update size automatically: sizing_node is null.")
				return
			
			_tween_state = TweenStates.NOT_TWEENING
			
			if full_size == get_size():
				_opened_state = target_opened_state 
			else: 
				_opened_state = OpenedStates.NOT_FULLY_OPENED
			
			_emit_tween_interrupted(previous_tween_state, _tween_state, _opened_state)
			_emit_opened_state_signal(previous_opened_state, _opened_state)
	else:
		_auto_size_to_full.call_deferred()

# Called each [method _process] or [method _physics_process] function depending on value of
# [member tween_in_physics_process] when tweening.
# Uses [method Tween.interpolate_value] to increment the tween.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _increment_tween(delta) -> void:
	_tween_elapsed_time += delta
	_tween_time_left = tween_duration_sec - _tween_elapsed_time
	
	get_normalized_size_or_null()
	
	if _tween_time_left <= 0: # tween is over
		set_custom_minimum_size(_tween_final_value)
		set_size(_tween_final_value)
		
		var previous_tween_state = _tween_state
		set_to_end_tween(false)
	
	else: # tween is not over:
		var interpolated_size = Tween.interpolate_value(
			_tween_initial_value, 
			_tween_delta_value, 
			_tween_elapsed_time, 
			tween_duration_sec, 
			tween_transition_type, 
			tween_ease_type)
		
		set_custom_minimum_size(interpolated_size)
		set_size(interpolated_size)
	
#	if _tween_elapsed_time < tween_duration_sec:
#		_tween_elapsed_time += delta
#		_tween_time_left = tween_duration_sec - _tween_elapsed_time
#		var interpolated_size = Tween.interpolate_value(
#			_tween_initial_value, 
#			_tween_delta_value, 
#			_tween_elapsed_time, 
#			tween_duration_sec, 
#			tween_transition_type, 
#			tween_ease_type)
#
#		set_custom_minimum_size(interpolated_size)
#		set_size(interpolated_size)
#	else:
#		# tween completed.
#		var previous_tween_state = _tween_state
#		set_to_end_tween(false)



# Called before starting any tween. Sets up all variables to be used with
# [method Tween.interpolate_value] which is used within [member _increment_tween].
# Includes: [member _tween_elapsed_time], [member _tween_initial_value], 
# [member _tween_final_value] and [member _tween_delta_value]
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _set_tween_variables(tween_target : Vector2, restart : bool = true) -> void:
	if restart:
		_tween_elapsed_time = 0.0
	
	_tween_initial_value = get_size()
	
	tween_target = tween_target
	_tween_final_value = tween_target
	_tween_delta_value = _tween_final_value - _tween_initial_value

# Called when the sizing node is resized. Can auto resize if [member auto_update_size] is enabled.
func _sizing_node_resized() -> void:
	_auto_size_to_full.call_deferred()

# Returns a constant from the [enum OpenedStates] enum, which 
# will be what the [member _opened_state] is set to after the current
# tween is over.
# Prints warning if this function is used when no tween is running. 
# [br][br] Can be used externally without any problems (won't break something).
func _get_target_opened_state(current_tween_state) -> OpenedStates:
	match current_tween_state:
		TweenStates.OPENING, TweenStates.AUTO_TWEENING_OPEN:
			return OpenedStates.OPENED
		TweenStates.CLOSING, TweenStates.AUTO_TWEENING_CLOSE:
			return OpenedStates.CLOSED
		TweenStates.FORCE_TWEENING: # equivalent to: TweenStates.FORCE_TWEENING:
			return OpenedStates.FORCE_SIZED
		_: 
			_print_warning_in_game_and_editor("attempt to get target opened state when not tweening.")
			return _opened_state

# Note: this method may be doing too much or should be renamed.
#
# Should add return [Vector2, OpenedStates] once the following is merged: 
# Ideally, can return a null even if have "-> [Vector2, OpenedStates]".
# https://github.com/godotengine/godot/pull/76843
#
# Gets the full size, which may be the open size or the close size, depending 
# on which states ([member _opened_state] and [member _tween_state]) are 
# currently set.
# [br]Also returns the target opened state: what the the [member _opened_state] 
# value will be after the current potentially occurring tween.
# [br][br] Return value is: [Vector2, OpenedStates] where Vector2 may be null
# if the sizing_node is used but is not set to anything.
# [br][br] Can be used externally without any problems (won't break something).
func _get_full_size_or_null_and_target_opened(): # -> [Vector2, OpenedStates]:
	var full_size # Ideally set to Vector2 even if could be null.
	var target_opened_state : OpenedStates
	if is_tweening():
		match _tween_state: # Will not be NOT_TWEENING.
			TweenStates.CLOSING, TweenStates.AUTO_TWEENING_CLOSE:
				full_size = get_closed_size_or_null()
				target_opened_state = OpenedStates.CLOSED
			_:
				full_size = get_opened_size_or_null()
				target_opened_state = OpenedStates.OPENED
	else:
		match _opened_state: # Will not be TWEENING.
			OpenedStates.CLOSED: 
				full_size = get_closed_size_or_null()
				target_opened_state = OpenedStates.CLOSED
			_:
				full_size = get_opened_size_or_null()
				target_opened_state = OpenedStates.OPENED
	
	return [full_size, target_opened_state]

# Called by [signal Control.tree_exiting] on the [member _sizing_node].
# Sets the [member sizing_node_path] to an empty NodePath.
# Calls the [method set_sizing_node_path]
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _sizing_node_exiting() -> void:
	if _in_game():
		set_sizing_node_path(NodePath(""))

# Emits necessary _opened_state signals ([signal state_set] and 
# [signal state_changed]). Only in game.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _emit_opened_state_signal(previous_state : OpenedStates, new_state : OpenedStates) -> void:
	if _in_game():
		state_set.emit(new_state, previous_state)

# Checks if in game before emitting [signal tween_started].
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _emit_tween_started(current_tween_state : TweenStates) -> void:
	if _in_game():
		tween_started.emit(current_tween_state)

# Unsure about indentation levels in this function matching style guides:
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#indentation
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#format-multiline-statements-for-readability
# Sends [signal tween_interrupted] signal if needed. Only in game.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
# Does not emit if next_state is an AUTO_TWEEN. 
func _emit_tween_interrupted(
		previous_tween_state : TweenStates, 
		next_tween_state : TweenStates, 
		next_opened_state : OpenedStates) -> void:
	if _in_game():
		# If same AUTO_TWEEN, then does not count as an interruption.
		if (
			(previous_tween_state == TweenStates.AUTO_TWEENING_OPEN
			and next_tween_state== TweenStates.AUTO_TWEENING_OPEN)
			or (previous_tween_state == TweenStates.AUTO_TWEENING_CLOSE
			and next_tween_state== TweenStates.AUTO_TWEENING_CLOSE)
			):
				return
				
		tween_interrupted.emit(previous_tween_state, next_tween_state, next_opened_state)

# Checks if in game before emitting [signal tween_completed].
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _emit_tween_completed(previous_tween_state : TweenStates) -> void:
	if _in_game():
		tween_completed.emit(previous_tween_state)

# Called on [signal Control.minimum_size_changed] on this node.
# Emits the [signal tweening_amount_changed] signal if tweening. 
# Can also emit in editor.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _emit_tween_amount_changed() -> void:
	if is_tweening():
		var current_size : Vector2 = get_custom_minimum_size()
		var initial_size : Vector2 = _tween_initial_value
		var target_size : Vector2 = _tween_final_value
		
		var current_distance: float = (current_size - initial_size).length()
		var total_distance: float = (target_size - initial_size).length()
		var normalized_progress : float = current_distance / total_distance
		
		# If in editor, only "emit" if the script the signal's callable is 
		# attached to is a tool script. 
		# Must "emit" by calling the callable
		# in this case instead of just doing emit().
		if _in_editor():
			# Ideally uses the type Array[Dictionary] but must just use Array for now...
			var connections_data : Array = tweening_amount_changed.get_connections()
			
			# For each dictionary in Array:
			for connection_data in connections_data: 
				# Get callable from dictionary.
				var callable : Callable = connection_data["callable"] 
				# Check if the script the callable is in, is a tool script (i.e., can run in editor).
				if callable.get_object().get_script().is_tool(): 
					# Call the callable.
					callable.call(get_custom_minimum_size(), normalized_progress, _tween_time_left) 
		else:
			tweening_amount_changed.emit(get_custom_minimum_size(), normalized_progress, _tween_time_left)

# Called by the buttons from collapsible_inspector_buttons.gd which are placed
# into the inspector. Does nothing if in-game.
# Editor equivalent to [method open], [method close], [method open_tween] and
# [method close_tween]. 
func _preview_button(open : bool) -> void:
	if _in_editor() and _can_preview():
		_change(open, _preview_tweening)

# Sets the [member _preview_enabled] value (useless in game).
# If disabled, will end any tweens by calling [method set_to_end_tween].
# If enabled, will set to full size if needed by calling [method _auto_size_to_full].
func _set_preview_enabled(enable_preview : bool) -> void:
	if _in_editor():
		_preview_enabled = enable_preview
		
		# Preview off: set tweening to end if running.
		if not enable_preview:
			set_to_end_tween() 
		else:
			# Set to full size and update states.
			_auto_size_to_full.call_deferred()

# Calls [member _preview_auto_update_size] on change for previewing.
func _set_preview_auto_update_size(preview_auto_size : AutoUpdateSizeOptions) -> void:
	if not is_node_ready() or not _can_preview(): # When just added to tree.
		_preview_auto_update_size = preview_auto_size 
		return
	_preview_auto_update_size = preview_auto_size 
	_auto_update_size_changed(_preview_auto_update_size)

# Sets [member _preview_tweening] (useless in-game).
# If disabled and tweening, will call [member set_to_end_tween].
func _set_preview_tweening(enable_preview_tweening : bool) -> void:
	if _in_editor():
		_preview_tweening = enable_preview_tweening
		
		if not _can_preview():
			return
		
		# Tweening off: ensures all tweens are ended.
		if not _preview_tweening: 
			set_to_end_tween()

# Returns largest x and y values from sizing_node.get_size() and 
# sizing_node.get_custom_minimum_size().
# For example if get_custom_minimum_size().x is larger than get_size().x 
# and get_size().y is larger than get_custom_minimum_size().y
# will return Vector2(get_custom_minimum_size().x, get_size().y).
# Prints warning if sizing_node is null as it cannot get its sizes.
# [br][br] Can be used externally without any problems (won't break something).
func _get_largest_size_value() -> Vector2:
	var target_node = get_sizing_node_or_null()
	
	var biggest : Vector2
	
	if target_node != null:
		if target_node.get_size().x > target_node.get_custom_minimum_size().x:
			biggest.x = target_node.get_size().x
		else:
			biggest.x = target_node.get_custom_minimum_size().x
			
		if target_node.get_size().y > target_node.get_custom_minimum_size().y:
			biggest.y = target_node.get_size().y
		else:
			biggest.y = target_node.get_custom_minimum_size().y
	else:
		_print_warning_in_game_or_err_in_editor("can't get largest size, sizing_node is null.")
	
	return biggest

# Called when [member sizing_constraint] or sizing flags 
# ([member Control.size_flags_horizontal] and 
# [member Control.size_flags_vertical]) are changed changed.
func _update_folding_direction() -> void:
	var direction : FoldingPreset = get_folding_direction_preset()
	_folding_direction_preset = direction

# Returns true if parent is a container or inherits from it.
func _has_parent_container() -> bool:
	return get_parent() is Container

# Uses both [method Control.set_custom_minimum_size] and [Control.method set_size]
# to set the size of the this node.
# [br][br][b]Warning:[/b] Should NOT be called externally (may break something). 
func _set_to_size(target_size : Vector2) -> void:
	set_custom_minimum_size(target_size)
	set_size(target_size)

# Calls [member Object.notify_property_list_changed]. Improves readability.
func _update_inspector() -> void:
	notify_property_list_changed()

# Check if in editor. Improves readability.
func _in_editor() -> bool:
	return Engine.is_editor_hint()

# Check if in game. Improves readability.
func _in_game() -> bool:
	return not Engine.is_editor_hint()

# Used to quickly know if in editor and preview is enabled.
func _can_preview() -> bool:
	return _in_editor() and _preview_enabled

# Uses [method print_rich] to print a string in yellow color into the editor's 
# output.
func _print_warning(string : String) -> void:
	print_rich("[color=yellow]" + string + "[/color]")

# Only if in game: calls [method _print_warning]
func _print_warning_in_game (warning : String) -> void:
	if _in_game():
		_print_warning(str(self, ": " , warning))

# In editor or in game: calls [method _print_warning]
func _print_warning_in_game_and_editor(warning : String) -> void:
	_print_warning(str(self, ": " , warning))

# Prints a string using [method printerr] if in game, but uses 
# [method _print_warning] if in editor.
func _print_warning_in_game_or_err_in_editor(warning : String) -> void:
	if _in_game(): # Only throw error when in game.
		printerr(str(self, ": ", warning))
	else:
		_print_warning(str(self, ": " , warning)) # Only prints warning if in editor.
