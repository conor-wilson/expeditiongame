class_name Map extends Node2D

# TODO: This is a very silly way to resolve the global position / local position issue. Fix this. 
const tile_global_position_offset:Vector2 = Vector2(32, 80)

@onready var background: MapTiles = $Background
@onready var markers: MapTiles = $Markers # Used for indicating placeable blocks and the exit tile
@onready var wind: MapTiles = $Wind
@onready var blocks: MapTiles = $Blocks
@onready var hover_ghosts: MapTiles = $HoverGhosts
@onready var red_hover_ghosts: MapTiles = $RedHoverGhosts

var hovered_block_coords:Vector2i = Vector2i(-1,-1 )# NOTE: Not 100% sure about this being here...


## TILE PLACEMENT FUNCS

func reset(blocks_config:MapTiles = null, wind_config:MapTiles = null, markers_config:MapTiles = null, background_config:MapTiles = null):
	
	# Copy from the configs, and make sure that they are hidden
	if blocks_config:
		blocks.copy_tiles(blocks_config)
		blocks_config.hide()
	if wind_config:
		wind.copy_tiles(wind_config)
		wind_config.hide()
	if markers_config:
		markers.copy_tiles(markers_config)
		markers_config.hide()
	if background_config:
		background.copy_tiles(background_config)
		background_config.hide()

func place_block(coords:Vector2i, block:Global.Block):
	blocks.set_block_tile(coords, block)

func attempt_to_place_hovered_tile(block:Global.Block) -> bool:
	if tile_is_placeable(hovered_block_coords):
		place_block(hovered_block_coords, block)
		return true
	else: 
		return false

func move_block(from_coords:Vector2i, to_coords:Vector2i):
	# TODO
	pass

func delete_block(coords:Vector2i):
	blocks.erase_cell(coords)

func hover_tile(coords:Vector2i, block:Global.Block):
	
	# Clear existing hovers
	hover_ghosts.clear()
	red_hover_ghosts.clear()
	
	# Hover on the new tile
	hovered_block_coords = coords
	if tile_is_placeable(coords):
		hover_ghosts.set_block_tile(coords, block)
	else:
		red_hover_ghosts.set_block_tile(coords, block)

func stop_hovering():
	hover_ghosts.clear()
	red_hover_ghosts.clear()
	hovered_block_coords = Vector2i(-1,-1)


## MAP STATE CHECKER FUNCS

func tile_is_block(coords:Vector2i, block:Global.Block) -> bool:
	return blocks.tile_is_block(coords, block)

func tile_is_blowable_wind(coords:Vector2i) -> bool:
	if !wind.tile_is_wind(coords):
		return false
	
	var blown_to_coords:Vector2i = wind.get_blown_to_coords_from_wind_tile(coords)
	if !tile_is_walkable(blown_to_coords):
		return false
	
	return true

func get_blown_to_coords_from_wind_tile(coords:Vector2i) -> Vector2i:
	return wind.get_blown_to_coords_from_wind_tile(coords)

func tile_is_placeable(coords:Vector2i) -> bool:
	return blocks.tile_is_within_map_area(coords) && (
		markers.tile_is_placeable(coords) &&
		blocks.tile_is_empty(coords)
	)

func tile_is_exit(coords:Vector2i) -> bool:
	return markers.tile_is_exit(coords)

func tile_is_walkable(coords:Vector2i) -> bool:
	return blocks.tile_is_within_map_area(coords) && (
		blocks.tile_is_empty(coords) ||
		tile_is_block(coords, Global.Block.WATER) ||
		tile_is_block(coords, Global.Block.FIRE)
	)

func tile_is_floodable(coords:Vector2i) -> bool:
	return blocks.tile_is_within_map_area(coords) && (
		blocks.tile_is_empty(coords) ||
		tile_is_block(coords, Global.Block.FIRE)
	)

func tile_is_flamable(coords:Vector2i) -> bool:
	return blocks.tile_is_within_map_area(coords) && (
		tile_is_block(coords, Global.Block.WOOD)
	)

func tile_is_deadly(coords:Vector2i) -> bool:
	return (
		tile_is_block(coords, Global.Block.WATER) ||
		tile_is_block(coords, Global.Block.FIRE)
	)

func get_block_tile_coords(block:Global.Block) -> Dictionary:
	
	var output:Dictionary = {}
	
	for coords in blocks.get_used_cells():
		if tile_is_block(coords, block):
			output[coords] = true
	
	return output


## OTHER FUNCS

func global_to_tile_coords(global_coords:Vector2) -> Vector2i:
	return blocks.local_to_map(global_coords - tile_global_position_offset)
