extends Node

## Logic for changing the container sizing of the CollapsibleContainer to
## demonstrate the different directions it can fold/unfold in.

# The same as Control.LayoutPreset enum but can reference its keys unlike built-in 
# enums. Just used to print the keys as strings. 
# Can also make into strings like how the size_flag_to_string() function
# makes Control.SizeFlags into strings, but this is just another way.
enum LayoutPreset {
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
}

@export var images : Array[Texture2D]
@export var collapsible : CollapsibleContainer
@export var texture_button : TextureButton # Could use a TextureRect instead.
@export var anchor_label : Label

# Randomizes so that the images/layout directions are different each time.
func _ready() -> void:
	randomize()

## Returns a string version of the Control.SizeFlags value provided.
## If parameters does not correspond to a SizeFlag, then will return "[invalid]"
## and print an error.
func size_flag_to_string(flag : int) -> String:
	match flag:
		Control.SIZE_SHRINK_BEGIN:
			return "SIZE_SHRINK_BEGIN"
		Control.SIZE_FILL:
			return "SIZE_FILL"
		Control.SIZE_EXPAND:
			return "SIZE_EXPAND"
		Control.SIZE_EXPAND_FILL:
			return "SIZE_EXPAND_FILL"
		Control.SIZE_SHRINK_CENTER:
			return "SIZE_SHRINK_CENTER"
		Control.SIZE_SHRINK_END:
			return "SIZE_SHRINK_END"
		_:
			printerr("invalid size flag: [", flag ,"]... may be using an another version of Godot compared to the one this example was made in.")
			return "[invalid]"

## Connects collapsible's tween_completed signal to continous_completed() which
## will restart the tween with randomized images + randomized direction.
func continous_pressed() -> void:
	if not collapsible.tween_completed.is_connected(continous_completed):
		collapsible.tween_completed.connect(continous_completed)
	collapsible.open_tween_toggle.call_deferred()

## Disconnects the collapsible tween_completed signal to continous_completed
## making the continous opening/closing toggle stop.
func toggle_collapsible() -> void:
	if collapsible.tween_completed.is_connected(continous_completed):
		collapsible.tween_completed.disconnect(continous_completed)
	collapsible.open_tween_toggle.call_deferred()

## Randomly selects an image from the images array and sets it to the 
## texture_button's texture_normal.
func change_image() -> void:
	var rand_img = randi_range(0, images.size() - 1)
	texture_button.texture_normal = images[rand_img]

## Randomly selects a LayoutPreset and uses the collapsible's set_folding_direction_preset()
## function to set its size (and its sizing_constraint) to determine its folding
## direction. 
## Also can set the child texture_button's LayoutPreset to change what 
## side it clings to when the collapsible is opening/closing, but that line is commented out for now.
func change_anchor() -> void:
	var rand_layout = randi_range(0, LayoutPreset.keys().size() - 1)
	
	collapsible.set_folding_direction_preset(rand_layout)
	#texture_button.set_anchors_and_offsets_preset(rand_layout, Control.PRESET_MODE_KEEP_SIZE) # What side the child clings to.
	
	# Convert LayoutPreset and ContainerSizing used into strings.
	var layout_preset : String = str(LayoutPreset.keys()[rand_layout])
	var verical_container_size : String = size_flag_to_string(collapsible.get_v_size_flags())
	var horizontal_container_size : String = size_flag_to_string(collapsible.get_h_size_flags())
	
	anchor_label.text = layout_preset + ": \n" + verical_container_size + " - " + horizontal_container_size

## If the opening tween just finished, begins closing tween. If closing just finished,
## restarts the collapsible's open tween after randomly selecting an image 
## (by calling change_image() and container sizing for the collapsible (by
## calling change_anchor). 
func continous_completed (re : CollapsibleContainer.TweenStates):
	if re == CollapsibleContainer.TweenStates.CLOSING:
		# ensure is closed fully. 
		# depending on sizing_constraint, may only close the height/width and not both.
		# force_sizing to (0, 0) ensures both are closed.
		# call_deferred is recommended anytime size is changed. Hence using it here.
		collapsible.force_size.call_deferred(Vector2.ZERO) 
		change_image()
		change_anchor()
		collapsible.open_tween_toggle.call_deferred()
	else:
		collapsible.open_tween_toggle.call_deferred()
