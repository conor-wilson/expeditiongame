class_name Character extends TileMapLayer

@export var map:Map
@export var start_position:Vector2i # TODO: Maybe make this a Marker2D as well?

var tilemap_source:int = 0
var tilemap_atlas_coords:Vector2i = Vector2i(0,0)

var alive:bool = true
var current_coords:Vector2i


## INITIALISATION FUNCS

func _ready() -> void:
	reset()

func set_map(new_map):
	map = new_map


## TILE PLACEMENT FUNCS

func reset() -> void:
	teleport(start_position)
	alive = true
	modulate = Color.WHITE

func teleport(new_coords:Vector2i):
	clear()
	current_coords = new_coords
	set_cell(new_coords, tilemap_source, tilemap_atlas_coords)

func walk(direction:Vector2i) -> bool:
	if !alive:
		return false
	
	var new_coords = current_coords+direction
	if map.tile_is_walkable(new_coords):
		teleport(new_coords)
		return true
	
	return false

func kill():
	alive = false
	modulate = Color.RED
	# TODO: Add some alternative tiles for death


## TILE STATE CHECKER FUNCS

func get_current_coords() -> Vector2i:
	return current_coords
