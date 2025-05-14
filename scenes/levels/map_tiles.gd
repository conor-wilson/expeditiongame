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

const static_tiles_source_id:int = 0
const placeable_atlas_coords:Vector2i = Vector2i(3,0)
const exit_atlas_coords:Vector2i = Vector2i(0,1)
const border_atlas_coords:Vector2i = Vector2i(0,0)


## TILE STATE CHECKER FUNCS

func tile_is_block(coords:Vector2i, block:Global.Block) -> bool:
	return (
		get_cell_source_id(coords) == block_source_id &&
		get_cell_atlas_coords(coords) == block_atlas_coords[block]
	)

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

## TILE PLACEMENT FUNCS

func set_block_tile(coords:Vector2i, block:Global.Block):
	set_cell(coords, block_source_id, block_atlas_coords[block])
