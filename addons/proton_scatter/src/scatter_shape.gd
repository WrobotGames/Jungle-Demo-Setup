@tool
extends Node3D


const ScatterUtil := preload('./common/scatter_util.gd')


@export_category("ScatterShape")
@export var negative = false:
	set(val):
		negative = val
		update_gizmos()
		ScatterUtil.request_parent_to_rebuild(self)

@export var shape: ProtonScatterBaseShape:
	set(val):
		# Disconnect the previous shape if any
		if shape and shape.changed.is_connected(_on_shape_changed):
			shape.changed.disconnect(_on_shape_changed)

		shape = val
		if shape:
			shape.changed.connect(_on_shape_changed)

		update_gizmos()
		ScatterUtil.request_parent_to_rebuild(self)

var _ignore_transform_notification = false


func _ready() -> void:
	set_notify_transform(true)


func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			if _ignore_transform_notification:
				_ignore_transform_notification = false
				return
			ScatterUtil.request_parent_to_rebuild(self)

		NOTIFICATION_ENTER_WORLD:
			_ignore_transform_notification = true


func _set(property, _value):
	if not Engine.is_editor_hint():
		return false

	# Workaround to detect when the node was duplicated from the editor.
	if property == "transform":
		_on_node_duplicated.call_deferred()

	return false


func _on_shape_changed() -> void:
	update_gizmos()
	ScatterUtil.request_parent_to_rebuild(self)


func _on_node_duplicated() -> void:
	shape = shape.get_copy() # Enfore uniqueness on duplicate, could be an option
