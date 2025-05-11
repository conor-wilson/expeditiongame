extends Node2D


# TODO: A func that sets up the inventory from a dict. Should make use of InventoryManager. 

func _on_slot_selected() -> void:
	for slot in $Slots.get_children():
		if slot is InventorySlot:
			slot.check_selected()
