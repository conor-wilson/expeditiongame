class_name TileButton extends Button

# TODO: Add a texture to focus so that tiles already holding blocks are visibly highlighted.

signal hovered(TileButton)

func _on_focus_entered() -> void:
	hovered.emit(self)

func _on_mouse_entered() -> void:
	hovered.emit(self)
	grab_focus()
