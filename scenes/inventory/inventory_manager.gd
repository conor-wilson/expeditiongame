extends Node

signal inventory_updated

var inventory:Dictionary = {
	Global.Block.WOOD: 0,
	Global.Block.STONE: 0,
	Global.Block.WATER: 0,
	Global.Block.FIRE: 0,
}
var selected_block:Global.Block = Global.Block.EMPTY

func subtract_from_selected_block():
	inventory[selected_block] -= 1
	
	if inventory[selected_block] <= 0:
		set_selected_block(Global.Block.EMPTY)
		CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	
	inventory_updated.emit()

# Inventory Getters and Setters

func set_inventory(new_inventory:Array[Global.Block]):
	
	inventory = {
		Global.Block.WOOD: 0,
		Global.Block.STONE: 0,
		Global.Block.WATER: 0,
		Global.Block.FIRE: 0,
	}
	
	for block in new_inventory:
		if block != Global.Block.EMPTY:
			inventory[block] += 1
	
	inventory_updated.emit()

func get_inventory() -> Dictionary:
	return inventory

func inventory_is_empty() -> bool:
	return (
		inventory[Global.Block.WOOD] == 0 &&
		inventory[Global.Block.STONE] == 0 &&
		inventory[Global.Block.WATER] == 0 &&
		inventory[Global.Block.FIRE] == 0
	)

# Selected Block Getters and Setters

func set_selected_block(new_block:Global.Block):
	selected_block = new_block

func get_selected_block() -> Global.Block:
	return selected_block

func selected_block_is(block:Global.Block) -> bool:
	return block == selected_block
