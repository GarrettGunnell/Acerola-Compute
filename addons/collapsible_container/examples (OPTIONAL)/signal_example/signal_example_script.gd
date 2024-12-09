extends Node

## Logic which handles setting important variables in the CollapsibleContainer
## to showcases how they affect how the node works.
## Also listens for CollapsibleContainer signals to showcase how they work.

@export var collapsible : CollapsibleContainer
@export var sizing_node_1 : Control
@export var sizing_node_2 : Control

@export_group("Signal Labels")
@export var state_set_label : Label
@export var tween_started_label : Label
@export var tween_completed_label : Label
@export var tween_amount_changed_label : Label
@export var tween_interrupted_label : Label

@export_group("Info Labels")
@export var tween_settings_info : Label
@export var custom_sizes_info : Label
@export var sizing_node_info : Label
@export var constraint_info : Label
@export var auto_update_info : Label
@export var force_size_info : Label
@export var force_tween_info : Label

# Tweens: set the label's colors to green and tween back to normal.
@onready var state_set_tween : Tween = create_tween()
@onready var tween_started_tween : Tween = create_tween()
@onready var tween_completed_tween : Tween = create_tween()
@onready var tween_amount_changed_tween : Tween = create_tween()
@onready var tween_interrupted_tween : Tween = create_tween()

# Unnecessary error print if don't stop all the tweens now. 
func _ready() -> void:
	state_set_tween.stop()
	tween_started_tween.stop()
	tween_completed_tween.stop()
	tween_amount_changed_tween.stop()
	tween_interrupted_tween.stop()


func toggle_open() -> void:
	collapsible.open_toggle()


func toggle_tweening() -> void:
	collapsible.open_tween_toggle()


func set_to_end_tween() -> void:
	collapsible.set_to_end_tween()


func force_stop_tween() -> void:
	collapsible.force_stop_tween()


# Changes the tween settings between 2 selections.
func toggle_tween_settings() -> void:
	var info_text : String
	if not collapsible.get_tween_in_physics_process():
		collapsible.set_tween_in_physics_process(true)
		collapsible.set_tween_transition_type(Tween.TRANS_EXPO)
		collapsible.set_tween_duration_sec(0.2)
		collapsible.set_tween_ease_type(Tween.EASE_OUT_IN)
		info_text = "TRANS_EXPO\nEASE_OUT_IN\nduration = 0.2"
	else:
		collapsible.set_tween_in_physics_process(false)
		collapsible.set_tween_transition_type(Tween.TRANS_SINE)
		collapsible.set_tween_duration_sec(0.5)
		collapsible.set_tween_ease_type(Tween.EASE_OUT)
		info_text = "TRANS_SINE\nEASE_OUT\nduration = 0.5"

	tween_settings_info.set_text(info_text)

# Sets custom open and close sizes if toggled on. 
# If toggled off, sets use_custom_open_size and use_custom_close_size to false.
func toggle_custom_sizes() -> void:
	var info_text : String
	
	if not collapsible.get_use_custom_open_size():
		# Just going to assume it wont be null, but you can always use an if statement to check.
		var fullsize : Vector2 = collapsible.get_opened_size_or_null() 
		
		# Set cusom open to half of full size:
		collapsible.set_custom_open_size(fullsize / 2) 
		
		# Set custom close to quarter of full size:
		collapsible.set_custom_close_size(fullsize / 4) 
		
		collapsible.use_custom_open_size = true
		collapsible.use_custom_close_size = true
		info_text = "custom open: " + str(fullsize / 2) + "\ncustom close: " + str(fullsize / 4) 
	else:
		collapsible.use_custom_open_size = false
		collapsible.use_custom_close_size = false
		info_text = "false" 
		
	custom_sizes_info.set_text(info_text)

# Changes sizing_node between 2 options.
func toggle_sizing_node() -> void:
	var info_text : String
	if collapsible.get_sizing_node_or_null() == sizing_node_1:
		collapsible.set_sizing_node_path(sizing_node_2.get_path())
		info_text = sizing_node_2.get_name()
	else:
		collapsible.set_sizing_node_path(sizing_node_1.get_path())
		info_text = sizing_node_1.get_name()

	sizing_node_info.set_text(info_text)

# Toggles the collapsible between the 3 different SizingConstraintOptions options.
# BOTH, ONLY_WIDTH AND ONLY_HEIGHT.
func toggle_constraint() -> void:
	var info_text : String
	# Toggles constraints from both, width, and height.
	var constraint : CollapsibleContainer.SizingConstraintOptions = collapsible.get_sizing_constraint()
	
	match constraint:
		CollapsibleContainer.SizingConstraintOptions.BOTH:
			collapsible.set_sizing_constraint(CollapsibleContainer.SizingConstraintOptions.ONLY_HEIGHT)
			info_text = CollapsibleContainer.SizingConstraintOptions.keys()[CollapsibleContainer.SizingConstraintOptions.ONLY_HEIGHT]
		CollapsibleContainer.SizingConstraintOptions.ONLY_HEIGHT:
			collapsible.set_sizing_constraint(CollapsibleContainer.SizingConstraintOptions.ONLY_WIDTH)
			info_text = CollapsibleContainer.SizingConstraintOptions.keys()[CollapsibleContainer.SizingConstraintOptions.ONLY_WIDTH]
		CollapsibleContainer.SizingConstraintOptions.ONLY_WIDTH:
			collapsible.set_sizing_constraint(CollapsibleContainer.SizingConstraintOptions.BOTH)
			info_text = CollapsibleContainer.SizingConstraintOptions.keys()[CollapsibleContainer.SizingConstraintOptions.BOTH]
	constraint_info.set_text(info_text)

# Toggles the collapsible between the 3 different AutoUpdateSizeOptions options.
# DISABLED, WITH_TWEEN AND WITHOUT_TWEEN.
func toggle_auto_size_update() -> void:
	var info_text : String
	var auto_options : CollapsibleContainer.AutoUpdateSizeOptions = collapsible.get_auto_update_size()
	
	match auto_options:
		CollapsibleContainer.AutoUpdateSizeOptions.DISABLED:
			collapsible.set_auto_update_size(CollapsibleContainer.AutoUpdateSizeOptions.WITH_TWEEN)
			info_text = CollapsibleContainer.AutoUpdateSizeOptions.keys()[CollapsibleContainer.AutoUpdateSizeOptions.WITH_TWEEN]
		CollapsibleContainer.AutoUpdateSizeOptions.WITH_TWEEN:
			collapsible.set_auto_update_size(CollapsibleContainer.AutoUpdateSizeOptions.WITHOUT_TWEEN)
			info_text = CollapsibleContainer.AutoUpdateSizeOptions.keys()[CollapsibleContainer.AutoUpdateSizeOptions.WITHOUT_TWEEN]
		CollapsibleContainer.AutoUpdateSizeOptions.WITHOUT_TWEEN:
			collapsible.set_auto_update_size(CollapsibleContainer.AutoUpdateSizeOptions.DISABLED)
			info_text = CollapsibleContainer.AutoUpdateSizeOptions.keys()[CollapsibleContainer.AutoUpdateSizeOptions.DISABLED]
	auto_update_info.set_text(info_text)

# Toggles between 2 different sizes and forcibly sets the collapsible's size 
# to selected.
func toggle_force_size() -> void:
	var forced_size := Vector2(50, 50)
	if collapsible.get_size() == forced_size:
		forced_size = Vector2(24, 52)
	force_size_info.set_text(str("forcing size to: ", forced_size))
	collapsible.force_size(forced_size)

# Toggles between 2 different sizes and forcibly tweens the collapsible's 
# size to selected.
func toggle_force_tween() -> void:
	var forced_size := Vector2(50, 50)
	if collapsible.get_size() == forced_size:
		forced_size = Vector2(24, 52)
	
	force_tween_info.set_text(str("forcing tween to: ", forced_size))
	collapsible.force_tween(forced_size)

#################################################################################
# Signals calls: functions are called by the collapsible's signals.
# Functions set the text detailing signal's meaning and tween the labels from
# green to normal. 

func state_set(new_state : CollapsibleContainer.OpenedStates, previous_state : CollapsibleContainer.OpenedStates) -> void:
	var previous_state_string : String = CollapsibleContainer.OpenedStates.keys()[previous_state]
	var new_state_string : String = CollapsibleContainer.OpenedStates.keys()[new_state]
	
	state_set_label.set_text(str("State Set: ", new_state_string + "\nPrevious State: " + previous_state_string))
	_tween_label_modulate(state_set_label, state_set_tween)


func tween_started(tween : CollapsibleContainer.TweenStates) -> void:
	tween_started_label.set_text(str("Tween Started: ", CollapsibleContainer.TweenStates.keys()[tween]))
	_tween_label_modulate(tween_started_label, tween_started_tween)


func tween_completed(tween : CollapsibleContainer.TweenStates) -> void:
	tween_completed_label.set_text(str("Tween Completed: ", CollapsibleContainer.TweenStates.keys()[tween]))
	_tween_label_modulate(tween_completed_label, tween_completed_tween)


func tween_amount_changed(current_size : Vector2, normalized_progress: float, time_left : float) -> void:
	tween_amount_changed_label.set_text(str("Tween Amount Changed: ", current_size, " [%.2f" % normalized_progress, "]", " [%.2f" % time_left, "]"))
	_tween_label_modulate(tween_amount_changed_label, tween_amount_changed_tween)


func tween_interrupted(
		previous_tween_state : CollapsibleContainer.TweenStates, 
		current_tween_state : CollapsibleContainer.TweenStates , 
		current_opened_state : CollapsibleContainer.OpenedStates) -> void:
	
	tween_interrupted_label.set_text(str(
			"Tween Interrupted: ", CollapsibleContainer.TweenStates.keys()[previous_tween_state], 
			"\n\t\tCurrent tween_state: ", CollapsibleContainer.TweenStates.keys()[current_tween_state], 
			"\n\t\tCurrent opened_state: ", CollapsibleContainer.OpenedStates.keys()[current_opened_state]
			))
	_tween_label_modulate(tween_interrupted_label, tween_interrupted_tween)

# Sets a label's modulate property to green and then tweens it back to normal.
func _tween_label_modulate(label : Label, label_tween : Tween) -> void:
	label_tween.stop()
	# Tween label's color:
	if label_tween.is_running():
		label_tween.stop()
	elif not label_tween.is_valid():
		# Must set the actual tween variable to a new tween, not just the label_tween.
		match label:
			state_set_label:
				state_set_tween = create_tween()
				label_tween = state_set_tween
			tween_started_label:
				tween_started_tween = create_tween()
				label_tween = tween_started_tween
			tween_completed_label:
				tween_completed_tween = create_tween()
				label_tween = tween_completed_tween
			tween_amount_changed_label:
				tween_amount_changed_tween = create_tween()
				label_tween = tween_amount_changed_tween
			tween_interrupted_label:
				tween_interrupted_tween = create_tween()
				label_tween = tween_interrupted_tween
	
	# Set to green and tween back to normal.
	label.set_self_modulate(Color.LIME_GREEN)
	label_tween.tween_property(label, "self_modulate", Color.WHITE, 1)
	label_tween.play()
