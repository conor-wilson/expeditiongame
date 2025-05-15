class_name Inventory extends Node2D

signal focus_grabbed

var inventory_dict:Dictionary
var selected_block:Global.Block

@onready var blocks: MapTiles = $Blocks
@onready var slots: Dictionary = {
	# TODO: Make this configurable
	Global.Block.WOOD:  $Slots/Slot0,
	Global.Block.STONE: $Slots/Slot1,
	Global.Block.WATER: $Slots/Slot2,
	Global.Block.FIRE:  $Slots/Slot3,
}

func _ready() -> void:
	set_empty_inventory_dict()


## INVENTORY SETUP FUNCS

func set_inventory_dict_from_array(inventory_array_config:Array[Global.Block] = []): 
	set_empty_inventory_dict()
	
	print("RECEIVED INVENTORY CONFIG: ", inventory_array_config)
	
	for block in inventory_array_config:
		inventory_dict[block] += 1
	
	refresh_slots()

func set_empty_inventory_dict():
	inventory_dict = {
		Global.Block.WOOD: 0,
		Global.Block.STONE: 0,
		Global.Block.WATER: 0,
		Global.Block.FIRE: 0,
	}

func set_selected_block(new_block:Global.Block):
	selected_block = new_block

func subtract_from_selected_block():
	inventory_dict[selected_block] -= 1
	
	if inventory_dict[selected_block] <= 0:
		set_selected_block(Global.Block.EMPTY)
		CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	
	refresh_slots()

func refresh_slots():
	slots[Global.Block.WOOD].set_contents(Global.Block.WOOD,  inventory_dict[Global.Block.WOOD])
	slots[Global.Block.STONE].set_contents(Global.Block.STONE, inventory_dict[Global.Block.STONE])
	slots[Global.Block.WATER].set_contents(Global.Block.WATER, inventory_dict[Global.Block.WATER])
	slots[Global.Block.FIRE].set_contents(Global.Block.FIRE,  inventory_dict[Global.Block.FIRE])


## INVENTORY STATE GETTER FUNCS

func get_selected_block() -> Global.Block:
	return selected_block

func selected_block_is(block:Global.Block) -> bool:
	return selected_block == block

func is_empty() -> bool:
	return (
		inventory_dict[Global.Block.WOOD] == 0 &&
		inventory_dict[Global.Block.STONE] == 0 &&
		inventory_dict[Global.Block.WATER] == 0 &&
		inventory_dict[Global.Block.FIRE] == 0
	)


## UI BEHAVIOUR FUNCS

func grab_focus():
	$Slots/Slot0.grab_focus()

func _on_slot_selected(slot:InventorySlot) -> void:
	deselect_all_slots()
	slot.select()
	set_selected_block(slot.get_block())

func deselect_all_slots():
	for block in slots:
		if slots[block] is InventorySlot:
			slots[block].deselect()

func _on_slot_focus_entered() -> void:
	focus_grabbed.emit()
