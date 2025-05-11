extends Node

var inventory = {}
var selected_block:Global.Block = Global.Block.EMPTY

func set_inventory(new_inventory):
	inventory = new_inventory

func set_selected_block(new_block:Global.Block):
	selected_block = new_block

func get_selected_block() -> Global.Block:
	return selected_block

func selected_block_is(block:Global.Block) -> bool:
	return block == selected_block
