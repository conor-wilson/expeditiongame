extends Node2D



func _on_slot_1_mouse_entered() -> void:
	$Inventory/Slot1/Highlight.show()
	#$Inventory/Slot1.scale = Vector2(1.05, 1.05)


func _on_slot_1_mouse_exited() -> void:
	$Inventory/Slot1/Highlight.hide()
	#$Inventory/Slot1.scale = Vector2(1, 1)
