class_name Character extends TileMapLayer

signal win

# TODO: Move much of this functionality to level.gd. Have this behave similarly to MapTiles

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
@export var map:Map
@export var start_position:Vector2i

var tilemap_source:int
var tilemap_coords:Vector2i
var character_coords:Vector2i

func _ready() -> void:
	tilemap_source = character_tilemap_sources[character_type]
	tilemap_coords = character_tilemap_coords[character_type]
	reset()

func reset(new_map:Map = map) -> void:
	teleport(start_position)
	map = new_map

func teleport(new_coords:Vector2i):
	clear()
	character_coords = new_coords
	set_cell(new_coords, tilemap_source, tilemap_coords)

func walk(direction:Vector2i) -> Vector2i:
	
	# Move the character if possible
	var new_coords = character_coords+direction
	if (!map.tile_is_walkable(new_coords) || 
		(!map.tile_is_walkable(character_coords+Vector2i(direction.x, 0)) && !map.tile_is_walkable(character_coords+Vector2i(0, direction.y)))):
		# TODO: Review this. It's messy.
		if new_coords.x && !map.tile_is_walkable(character_coords+Vector2i(direction.x, 0)):
			direction.x = 0
		if new_coords.y && !map.tile_is_walkable(character_coords+Vector2i(0, direction.y)):
			direction.y = 0
		new_coords = character_coords+direction
	if !map.tile_is_walkable(new_coords):
		return Vector2i.ZERO
	
	teleport(new_coords)
	
	# Check for win condition for player
	if character_type == CharacterType.PLAYER && map.tile_is_exit(character_coords):
		win.emit()
	
	return direction

func get_character_coords() -> Vector2i:
	return character_coords
