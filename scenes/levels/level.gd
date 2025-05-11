extends Node2D

# TODO: This is a very silly way to resolve the global position / local position issue. Fix this. 
const tile_global_position_offset:Vector2 = Vector2(64, 160)

var hovered_tile_coords:Vector2 = Vector2i(0,0)

@export var block_tiles:TileMapLayer
@export var inventory:Array[Global.Block]
@export var player_start_position:Vector2i = Vector2i(5, 10)

var block_tilemap_coords:Dictionary = {
	Global.Block.EMPTY: Vector2i(-1,-1),
	Global.Block.WOOD:  Vector2(0,1),
	Global.Block.STONE: Vector2(1,1),
	Global.Block.WATER: Vector2(2,1),
	Global.Block.FIRE:  Vector2(3,1),
}

# TODO: Do some stuff with focus grabbing when resources run out

func _ready() -> void:
	for row in $TileButtons.get_children():
		for tile in row.get_children():
			if tile is TileButton:
				tile.connect("pressed", _on_tile_pressed)
				tile.connect("hovered", _on_tile_hovered)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		$Player.walk(Vector2i.UP)
	if Input.is_action_just_pressed("down"):
		$Player.walk(Vector2i.DOWN)
	if Input.is_action_just_pressed("left"):
		$Player.walk(Vector2i.LEFT)
	if Input.is_action_just_pressed("right"):
		$Player.walk(Vector2i.RIGHT)


func load():
	
	# TODO: Reset tiles
	
	# Reset the inventory
	InventoryManager.set_inventory(inventory)
	$Inventory.refresh_inventory()
	
	# Move the Player to the start position
	$Player.teleport(player_start_position)

func _on_tile_pressed() -> void:
	
	if block_tiles == null:
		push_error("tile clicked on level that has no block tiles")
	
	if _block_can_be_placed_on_cell(hovered_tile_coords):
		place_block(hovered_tile_coords)

func place_block(coords:Vector2i):
	block_tiles.set_cell(coords, 0, block_tilemap_coords[InventoryManager.get_selected_block()])
	InventoryManager.subtract_from_selected_block()
	$Inventory.refresh_inventory()

func _on_tile_hovered(button:TileButton):
	
	hovered_tile_coords = _get_map_tile_coords(button.global_position)
	
	print("hovered_tile_coords: ", hovered_tile_coords)
	$HoverGhosts.clear()
	if !InventoryManager.selected_block_is(Global.Block.EMPTY):
		$HoverGhosts.set_cell(hovered_tile_coords, 0, block_tilemap_coords[InventoryManager.get_selected_block()])

# _block_can_be_placed_on_cell returns true if the cell at the provided coordinates is empty 
# (checks Blocks layer).
func _block_can_be_placed_on_cell(coords : Vector2i) -> bool:
	return (
		!InventoryManager.selected_block_is(Global.Block.EMPTY) &&
		block_tiles.get_cell_tile_data(coords) == null
		)

func _get_map_tile_coords(global_coords:Vector2) -> Vector2i:
	return block_tiles.local_to_map(global_coords - tile_global_position_offset)


func _on_inventory_focus_grabbed() -> void:
	hovered_tile_coords = Vector2i(-1,-1)
	$HoverGhosts.clear()


# TODO: Make the below work

func _on_game_area_mouse_exited() -> void:
	hovered_tile_coords = Vector2i(-1,-1)
	$HoverGhosts.clear()
	print("YO")
