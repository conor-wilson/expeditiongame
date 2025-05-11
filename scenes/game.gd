extends Node2D


var block_tilemap_coords = {
	Global.Block.EMPTY: Vector2i(-1,-1),
	Global.Block.WOOD:  Vector2(0,1),
	Global.Block.STONE: Vector2(1,1),
	Global.Block.WATER: Vector2(2,1),
	Global.Block.FIRE:  Vector2(3,1),
}

func _on_map_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") && !InventoryManager.selected_block_is(Global.Block.EMPTY):
		
		# TODO: Check if block has hilighted sprite
		var cell_coords:Vector2i = $Blocks.local_to_map($Blocks.get_local_mouse_position())
		$Blocks.set_cell(cell_coords, 0, block_tilemap_coords[InventoryManager.get_selected_block()])
