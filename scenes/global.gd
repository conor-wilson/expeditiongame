extends Node

## NOTE: if any extra block types are added, ensure that InventoryManager.is_empty() is updated.
enum Block {
	EMPTY,
	WOOD,
	STONE,
	WATER,
	FIRE,
	#HOUSE, # Maybe
	#CAVE,  # Maybe
}
