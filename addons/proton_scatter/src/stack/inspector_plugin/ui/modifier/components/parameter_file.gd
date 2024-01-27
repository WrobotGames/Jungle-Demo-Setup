@tool
extends "base_parameter.gd"


@onready var _label: Label = $%Label
@onready var _select_button: Button = $%FileButton
@onready var _dialog: FileDialog = $%FileDialog
@onready var _texture: Button = $%TextureButton
@onready var _preview_root: Control = $%PreviewRoot

var _path := ""
var _is_texture := false


func set_parameter_name(text: String) -> void:
	_label.text = text


func set_hint_string(hint: String) -> void:
	_is_texture = hint == "Texture"
	_set_value(get_value())


func _set_value(val: String) -> void:
	_path = val
	_select_button.text = val.get_file()
	_preview_root.visible = false

	if val.is_empty():
		_select_button.text = "Select a file"

	if _is_texture:
		var texture = load(get_value())
		if texture is Texture:
			_texture.icon = texture
			_preview_root.visible = true


func get_value() -> String:
	return _path


func _on_clear_button_pressed() -> void:
	_set_value("")
	_on_value_changed("")


func _on_select_button_pressed() -> void:
	_dialog.popup_centered()


func _on_file_selected(file: String) -> void:
	_set_value(file)
	_on_value_changed(file)
