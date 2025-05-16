class_name Enemy extends Character

enum Kind {
	GOBLIN,
	ANGRY_RED_MAN
}
@export var kind:Kind

const character_tilemap_sources:Dictionary = {
	Kind.GOBLIN: 1,
	Kind.ANGRY_RED_MAN: 1,
}
const character_tilemap_atlas_coords:Dictionary = {
	Kind.GOBLIN: Vector2i(0,1),
	Kind.ANGRY_RED_MAN: Vector2i(0,0),
}


## INITIALISATION FUNCS

func _ready() -> void:
	tilemap_source = character_tilemap_sources[kind]
	tilemap_atlas_coords = character_tilemap_atlas_coords[kind]
	reset()


## TILE PLACEMENT FUNCS

func follow_player(player_coords):
	if !alive: 
		return
	walk(get_next_tile_direction(player_coords))


## TILE STATE GETTER FUNCS

func get_next_tile_direction(player_coords) -> Vector2i:
	
	var direction:Vector2i = player_coords - current_coords
	direction = direction.clamp(Vector2i(-1,-1), Vector2i(1,1))
	
	match kind:
		Kind.GOBLIN:
			return direction.clamp(Vector2i(0,-1), Vector2i(0,1))
		Kind.ANGRY_RED_MAN:
			return direction.clamp(Vector2i(-1,0), Vector2i(1,0))
	
	return get_current_coords()

func get_next_tile_coords(player_coords) -> Vector2i:
	return get_current_coords() + get_next_tile_direction(player_coords)
