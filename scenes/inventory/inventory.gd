extends Node2D

signal focus_grabbed

func refresh_inventory():
	var inventory:Dictionary = InventoryManager.get_inventory()
	
	# TODO: Make it so that the inventory slots aren't necessarily the same block every time
	
	$Slots/Slot0.set_contents(Global.Block.WOOD,  inventory[Global.Block.WOOD])
	$Slots/Slot1.set_contents(Global.Block.STONE, inventory[Global.Block.STONE])
	$Slots/Slot2.set_contents(Global.Block.WATER, inventory[Global.Block.WATER])
	$Slots/Slot3.set_contents(Global.Block.FIRE,  inventory[Global.Block.FIRE])

func grab_focus():
	$Slots/Slot0.grab_focus()

func _on_slot_selected() -> void:
	for slot in $Slots.get_children():
		if slot is InventorySlot:
			slot.check_selected()


func _on_slot_focus_entered() -> void:
	focus_grabbed.emit()
