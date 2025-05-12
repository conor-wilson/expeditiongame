class_name Character extends TileMapLayer

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

enum CharacterType {
	PLAYER,
	GOBLIN,
	ANGRY_RED_MAN, #lmao
}
@export var character_type:CharacterType
@export var start_position:Vector2i


var tilemap_source:int
var tilemap_coords:Vector2i
var character_coords:Vector2i

func _ready() -> void:
	tilemap_source = character_tilemap_sources[character_type]
	tilemap_coords = character_tilemap_coords[character_type]
	reset()

func reset() -> void:
	teleport(start_position)

func teleport(new_coords:Vector2i):
	clear()
	character_coords = new_coords
	set_cell(new_coords, tilemap_source, tilemap_coords)

func walk(direction:Vector2i):
	teleport(character_coords+direction)

func get_character_coords() -> Vector2i:
	return character_coords
