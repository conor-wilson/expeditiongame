class_name Enemies extends Node2D

const ENEMY_SCENE = preload("res://scenes/characters/enemy.tscn")

@export var map:Map

# TODO: Do away with the Enemy type, and just use Character instead?

@onready var enemy_characters:Array[Enemy] = [
	#$Enemy0,
	#$Enemy1,
	#$Enemy2,
	#$Enemy3,
	#$Enemy4,
	#$Enemy5,
	#$Enemy6,
	#$Enemy7,
]

const character_type_from_tilemap_atlas_coords:Dictionary = {
	Vector2i(0,1): Enemy.Kind.GOBLIN,
	Vector2i(0,0): Enemy.Kind.ANGRY_RED_MAN,
}

func _ready() -> void:
	for enemy in enemy_characters:
		enemy.set_map(map)

func reset(enemies_config:TileMapLayer = null) -> void:
	remove_all_enemies()
	
	if enemies_config != null:
		print("YO")
		copy_enemies_from_config(enemies_config)

func remove_all_enemies():
	for enemy in enemy_characters:
		enemy.queue_free()
	enemy_characters = []

func copy_enemies_from_config(enemies_config:TileMapLayer) -> void:
	
	#var enemy_index:int = 0
	for coords in enemies_config.get_used_cells():
		print("enemies_config.get_cell_atlas_coords(coords): ", enemies_config.get_cell_atlas_coords(coords))
		if character_type_from_tilemap_atlas_coords.has(enemies_config.get_cell_atlas_coords(coords)):
			
			var character_kind:Enemy.Kind = character_type_from_tilemap_atlas_coords[enemies_config.get_cell_atlas_coords(coords)]
			print("character_kind: ", character_kind)
			add_new_enemy(character_kind, coords)
			
			#enemy_characters[enemy_index].set_kind(character_kind)
			#enemy_characters[enemy_index].start_position = coords
			#enemy_characters[enemy_index].reset()
			#enemy_characters[enemy_index].show()
			#enemy_index += 1
	
	enemies_config.hide()

func add_new_enemy(kind:Enemy.Kind, coords:Vector2i):
	
	# Instantiate the new enemy
	var new_enemy:Enemy = ENEMY_SCENE.instantiate()
	
	# Give the enemy its state
	print("kind: ", kind)
	new_enemy.set_kind(kind)
	new_enemy.start_position = coords
	new_enemy.map = map
	new_enemy.reset()
	
	# Add the enemy as a child of this scene
	add_child(new_enemy)
	enemy_characters.append(new_enemy)
	
	# Reset the enemy
