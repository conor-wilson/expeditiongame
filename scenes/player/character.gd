class_name Character extends TileMapLayer

@export var map:Map
@export var start_position:Vector2i # TODO: Maybe make this a Marker2D as well?

var tilemap_source:int = 0
var tilemap_atlas_coords:Vector2i = Vector2i(0,0)

var current_coords:Vector2i

## INITIALISATION FUNCS

func _ready() -> void:
	reset_position()

func set_map(new_map):
	map = new_map


## TILE PLACEMENT FUNCS

func reset_position() -> void:
	teleport(start_position)

func teleport(new_coords:Vector2i):
	clear()
	current_coords = new_coords
	set_cell(new_coords, tilemap_source, tilemap_atlas_coords)

func walk(direction:Vector2i) -> bool:
	
	var new_coords = current_coords+direction
	if map.tile_is_walkable(new_coords):
		teleport(new_coords)
		return true
	
	return false


## TILE STATE CHECKER FUNCS

func get_current_coords() -> Vector2i:
	return current_coords
