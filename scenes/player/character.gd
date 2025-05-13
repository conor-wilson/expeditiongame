class_name Character extends TileMapLayer

signal win

const MIN_X:int = 0
const MIN_Y:int = 0
const MAX_X:int = 10
const MAX_Y:int = 10

const character_tilemap_sources:Dictionary = {
	CharacterType.PLAYER: 0,
	CharacterType.GOBLIN: 1,
	CharacterType.ANGRY_RED_MAN: 1,
}
const character_tilemap_coords:Dictionary = {
	CharacterType.PLAYER: Vector2i(0,0),
	CharacterType.GOBLIN: Vector2i(0,1),
	CharacterType.ANGRY_RED_MAN: Vector2i(0,0),
}
const exit_tilemap_coords:Vector2i = Vector2i(0,1)

enum CharacterType {
	PLAYER,
	GOBLIN,
	ANGRY_RED_MAN, #lmao
}
@export var character_type:CharacterType
@export var block_layer:TileMapLayer
@export var start_position:Vector2i

var tilemap_source:int
var tilemap_coords:Vector2i
var character_coords:Vector2i

func _ready() -> void:
	tilemap_source = character_tilemap_sources[character_type]
	tilemap_coords = character_tilemap_coords[character_type]
	reset()

func reset(new_block_layer:TileMapLayer = block_layer) -> void:
	teleport(start_position)
	block_layer = new_block_layer

func teleport(new_coords:Vector2i):
	clear()
	character_coords = new_coords
	set_cell(new_coords, tilemap_source, tilemap_coords)

func walk(direction:Vector2i) -> bool:
	
	# Move the character if possible
	var new_coords = character_coords+direction
	if ((!_can_move_to_cell(character_coords+Vector2i(direction.x, 0)) && !_can_move_to_cell(character_coords+Vector2i(0, direction.y))) ||
		!_can_move_to_cell(new_coords)): 
		return false
	teleport(new_coords)
	
	# Check for win condition for player
	if character_type == CharacterType.PLAYER && _is_win_space(character_coords):
		win.emit()
	
	return true

func _can_move_to_cell(coords:Vector2i) -> bool:
	
	if (
		coords.x < MIN_X || coords.y < MIN_Y ||
		coords.x > MAX_X || coords.y > MAX_Y
		):
		return false
	
	return (
		block_layer.get_cell_tile_data(coords) == null ||
		_is_win_space(coords)
	)

func _is_win_space(coords) -> bool:
	return (
		block_layer.get_cell_source_id(coords) == 0 && 
		block_layer.get_cell_atlas_coords(coords) == exit_tilemap_coords
	)

func get_character_coords() -> Vector2i:
	return character_coords
