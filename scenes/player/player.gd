extends TileMapLayer

var character_coords:Vector2i

func teleport(new_coords:Vector2i):
	clear()
	character_coords = new_coords
	set_cell(new_coords, 0, Vector2i(0,0))

func walk(direction:Vector2i):
	teleport(character_coords+direction)

func get_character_coords() -> Vector2i:
	return character_coords
