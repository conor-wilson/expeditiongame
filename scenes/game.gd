extends Node2D



func _on_slot_1_mouse_entered() -> void:
	$Inventory/Slot1/Highlight.show()
	#$Inventory/Slot1.scale = Vector2(1.05, 1.05)


func _on_slot_1_mouse_exited() -> void:
	if !CursorManager.current_cursor_is(CursorManager.GREEN_BLOCK):
		$Inventory/Slot1/Highlight.hide()
	#$Inventory/Slot1.scale = Vector2(1, 1)



func _on_slot_1_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("GREEN BLOCK CLICKED")
		#$Inventory/Slot1.hide()
		#$Inventory/Slot1/Highlight.hide()
		CursorManager.set_mouse_cursor(CursorManager.GREEN_BLOCK)
