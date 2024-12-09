@tool
extends EditorPlugin

## Loads and removes the CollapsibleContainer inspector plugin.
## 
## Assigns CollapsibleContainer's member variable _editor_plugin to self.

var collapsible_container_inspector_plugin = preload("collapsible_container_inspector_plugin.gd")

func _enter_tree():
	collapsible_container_inspector_plugin = collapsible_container_inspector_plugin.new()
	add_inspector_plugin(collapsible_container_inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(collapsible_container_inspector_plugin)

# Lets CollapsibleContainer access the EditorPlugin class.
# Currently: just used by folding_presets.gd to create undo_redo's
# by using EditorUndoRedoManager.
func _handles(object: Object) -> bool:
	if object is CollapsibleContainer:
		object._editor_plugin = self
	
	return false
