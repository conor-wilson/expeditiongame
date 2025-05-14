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
	reset_position()


## TILE PLACEMENT FUNCS

func follow_player(player_coords):
	
	var direction:Vector2i = player_coords - current_coords
	direction = direction.clamp(Vector2i(-1,-1), Vector2i(1,1))
	
	match kind:
		Kind.GOBLIN:
			walk(direction.clamp(Vector2i(0,-1), Vector2i(0,1)))
		Kind.ANGRY_RED_MAN:
			walk(direction.clamp(Vector2i(-1,0), Vector2i(1,0)))
