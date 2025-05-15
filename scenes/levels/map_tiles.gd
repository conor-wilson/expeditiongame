class_name MapTiles extends TileMapLayer

const MIN_X:int = 0
const MIN_Y:int = 0
const MAX_X:int = 10
const MAX_Y:int = 10

const block_source_id:int = 1
const block_atlas_coords:Dictionary = {
	Global.Block.EMPTY: Vector2i(-1,-1),
	Global.Block.WOOD:  Vector2i(0,0),
	Global.Block.STONE: Vector2i(0,1),
	Global.Block.WATER: Vector2i(0,2),
	Global.Block.FIRE:  Vector2i(0,3),
}

const wind_atlas_coords:Vector2i = Vector2i(0,4)
const wind_alt_ids:Dictionary = {
	Vector2.UP:    1,
	Vector2.DOWN:  2,
	Vector2.LEFT:  3,
	Vector2.RIGHT: 4,
}

const static_tiles_source_id:int = 0
const placeable_atlas_coords:Vector2i = Vector2i(3,0)
const exit_atlas_coords:Vector2i = Vector2i(0,1)
const border_atlas_coords:Vector2i = Vector2i(0,0)


## TILE PLACEMENT FUNCS

func set_block_tile(coords:Vector2i, block:Global.Block):
	set_cell(coords, block_source_id, block_atlas_coords[block])

func set_wind_tile(coords:Vector2i, direction:Vector2):
	set_cell(coords, block_source_id, wind_atlas_coords, wind_alt_ids[direction])

func copy_tiles(from_map:MapTiles):
	clear()
	for coords in from_map.get_used_cells():
		set_cell(coords, from_map.get_cell_source_id(coords), from_map.get_cell_atlas_coords(coords), from_map.get_cell_alternative_tile(coords))


## TILE STATE CHECKER FUNCS

func tile_is_block(coords:Vector2i, block:Global.Block) -> bool:
	return (
		get_cell_source_id(coords) == block_source_id &&
		get_cell_atlas_coords(coords) == block_atlas_coords[block]
	)

func tile_is_wind(coords) -> bool:
	print("get_cell_source_id(coords): ", get_cell_source_id(coords))
	print("get_cell_atlas_coords(coords): ", get_cell_atlas_coords(coords))
	return (
		get_cell_source_id(coords) == block_source_id &&
		get_cell_atlas_coords(coords) == wind_atlas_coords
	)

func get_tile_wind_direction(coords) -> Vector2:
	print("FLAG1")
	if !tile_is_wind(coords):
		return Vector2.ZERO
		
	print("FLAG2")
	for direction in wind_alt_ids:
		if wind_alt_ids[direction] == get_cell_alternative_tile(coords):
			return direction
	
	print("FLAG3")
	return Vector2.ZERO

func tile_is_placeable(coords:Vector2i) -> bool:
	return (
		get_cell_source_id(coords) == static_tiles_source_id &&
		get_cell_atlas_coords(coords) == placeable_atlas_coords
	)

func tile_is_exit(coords:Vector2i) -> bool:
	return (
		get_cell_source_id(coords) == static_tiles_source_id &&
		get_cell_atlas_coords(coords) == exit_atlas_coords
	)

# NOTE: Make sure to update this if more border tiles get added
func tile_is_border(coords:Vector2i) -> bool:
	return (
		get_cell_source_id(coords) == static_tiles_source_id &&
		get_cell_atlas_coords(coords) == border_atlas_coords
	)

func tile_is_empty(coords:Vector2i) -> bool:
	return get_cell_tile_data(coords) == null

func tile_is_within_map_area(coords:Vector2i) -> bool:
	return (
		coords.x > MIN_X && coords.y > MIN_Y &&
		coords.x < MAX_X && coords.y < MAX_Y
		)
