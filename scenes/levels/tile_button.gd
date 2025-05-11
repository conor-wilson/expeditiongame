class_name TileButton extends Button

signal hovered(TileButton)

func _on_focus_entered() -> void:
	hovered.emit(self)

func _on_mouse_entered() -> void:
	hovered.emit(self)
