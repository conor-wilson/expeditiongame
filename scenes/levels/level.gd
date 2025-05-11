extends Node2D

var hovered_tile_coords:Vector2 = Vector2(0,0)

@export var block_tiles:TileMapLayer

var block_tilemap_coords = {
	Global.Block.EMPTY: Vector2i(-1,-1),
	Global.Block.WOOD:  Vector2(0,1),
	Global.Block.STONE: Vector2(1,1),
	Global.Block.WATER: Vector2(2,1),
	Global.Block.FIRE:  Vector2(3,1),
}

func _ready() -> void:
	for row in $TileButtons.get_children():
		for tile in row.get_children():
			if tile is TileButton:
				tile.connect("pressed", _on_tile_pressed)
				tile.connect("hovered", _on_tile_hovered)
	
	

func _on_tile_pressed() -> void:
	
	if block_tiles == null:
		push_error("tile clicked on level that has no block tiles")
	
	if !InventoryManager.selected_block_is(Global.Block.EMPTY):
		
		# TODO: Check if block has hilighted sprite
		var cell_coords:Vector2i = block_tiles.local_to_map(hovered_tile_coords)
		block_tiles.set_cell(cell_coords, 0, block_tilemap_coords[InventoryManager.get_selected_block()])

# TODO: This is a very silly way to resolve the global position / local position issue. Fix this. 
var tile_global_position_offset:Vector2 = Vector2(64, 160)

func _on_tile_hovered(button:TileButton):
	hovered_tile_coords = button.global_position - tile_global_position_offset
	print("hovered_tile_coords: ", hovered_tile_coords)
