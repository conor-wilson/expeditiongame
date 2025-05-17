class_name Enemies extends Node2D

const CHARACTER_SCENE = preload("res://scenes/characters/character.tscn")

@export var map:Map
@export var sub_tick_timer:Timer

# TODO: Do away with the Enemy type, and just use Character instead?

@onready var enemy_characters:Array[Character] = []


func _ready() -> void:
	for enemy in enemy_characters:
		enemy.set_map(map)


## TILE PLACEMENT FUNCS

func reset(enemies_config:TileMapLayer = null) -> void:
	remove_all_enemies()
	
	if enemies_config != null:
		copy_enemies_from_config(enemies_config)

func remove_all_enemies():
	for enemy in enemy_characters:
		enemy.queue_free()
	enemy_characters = []

func copy_enemies_from_config(enemies_config:TileMapLayer) -> void:
	
	for coords in enemies_config.get_used_cells():
		add_new_enemy(
			_get_enemy_type(enemies_config.get_cell_atlas_coords(coords)), 
			coords,
		)
	enemies_config.hide()

func add_new_enemy(enemy_type:EnemyType, coords:Vector2i):
	
	# Instantiate the new enemy
	var new_enemy:Character = CHARACTER_SCENE.instantiate()
	
	# Give the enemy its state
	new_enemy.tilemap_atlas_coords = _get_atlas_coords(enemy_type)
	new_enemy.tilemap_source = enemy_tileset_source
	new_enemy.start_position = coords
	new_enemy.set_map(map)
	new_enemy.reset()
	
	# Add the enemy as a child of this scene
	add_child(new_enemy)
	enemy_characters.append(new_enemy)

func follow_player(player_coords:Vector2i):
	
	# TODO: Spin out some of this functionality. No need for so much duplication
	
	# Move Goblins
	for enemy in enemy_characters:
		var enemy_type:EnemyType = _get_enemy_type(enemy.get_cell_atlas_coords(enemy.get_current_coords()))
		if enemy_type == EnemyType.GOBLIN && enemy.alive && !tile_contains_enemy(_get_next_tile_coords(enemy, player_coords)):
			enemy.walk(_get_next_tile_direction(enemy, player_coords))
	
	# Wait one subtick
	sub_tick_timer.start()
	await sub_tick_timer.timeout
	
	# Move Angry Red Men
	for enemy in enemy_characters:
		var enemy_type:EnemyType = _get_enemy_type(enemy.get_cell_atlas_coords(enemy.get_current_coords()))
		if enemy_type == EnemyType.ANGRY_RED_MAN && enemy.alive && !tile_contains_enemy(_get_next_tile_coords(enemy, player_coords)):
			enemy.walk(_get_next_tile_direction(enemy, player_coords))

func apply_wind():
	
	while true:
		
		# TODO: Clean up when two enemies are blown in a row
		
		# Build the dict of enemies not to be blown
		var enemies_not_to_be_blown:Dictionary = {}
		for enemy in enemy_characters:
			if !map.tile_is_blowable_wind(enemy.get_current_coords()):
				enemies_not_to_be_blown[enemy] = true
		
		# Add enemies from that would be blown onto another enemy's current space
		for enemy in enemy_characters:
			if tile_contains_enemy(map.get_blown_to_coords_from_wind_tile(enemy.get_current_coords())):
				enemies_not_to_be_blown[enemy] = true
		
		if len(enemies_not_to_be_blown) == len(enemy_characters):
			return
		
		## Wait one sub-tick
		sub_tick_timer.start()
		await sub_tick_timer.timeout
		
		# Blow the other enemies
		for enemy in enemy_characters: 
			if !enemies_not_to_be_blown.has(enemy):
				enemy.teleport(map.get_blown_to_coords_from_wind_tile(enemy.get_current_coords()))
				
				check_enemy_death()


## ENEMY STATE CHECKER FUNCS

func tile_contains_enemy(coords) -> bool:
	for enemy in enemy_characters:
		if enemy.get_current_coords() == coords:
			return true
	return false

func check_enemy_death():
	for enemy in enemy_characters:
		if map.tile_is_deadly(enemy.get_current_coords()):
			enemy.kill()

func _get_next_tile_direction(enemy:Character, player_coords:Vector2i) -> Vector2i:
	
	var direction:Vector2i = player_coords - enemy.current_coords
	direction = direction.clamp(Vector2i(-1,-1), Vector2i(1,1))
	
	match _get_enemy_type(enemy.get_cell_atlas_coords(enemy.get_current_coords())):
		EnemyType.GOBLIN:
			return direction.clamp(Vector2i(0,-1), Vector2i(0,1))
		EnemyType.ANGRY_RED_MAN:
			return direction.clamp(Vector2i(-1,0), Vector2i(1,0))
	
	return Vector2i.ZERO

func _get_next_tile_coords(enemy:Character, player_coords:Vector2i) -> Vector2i:
	return enemy.get_current_coords() + _get_next_tile_direction(enemy, player_coords)


## ENEMY TYPE FUNCTIONALITY
# NOTE: I know consts, enums and variables should be at the top of the file but
# there are exceptions to every rule and this is my project. SUE ME!

enum EnemyType {
	GOBLIN,
	ANGRY_RED_MAN
}
const enemy_type_to_atlas_coords:Dictionary = {
	EnemyType.GOBLIN: Vector2i(0,1),
	EnemyType.ANGRY_RED_MAN: Vector2i(0,0),
}
const atlas_coords_to_enemy_type:Dictionary = {
	Vector2i(0,1): EnemyType.GOBLIN,
	Vector2i(0,0): EnemyType.ANGRY_RED_MAN,
}
const enemy_tileset_source:int = 1

func _get_enemy_type(atlas_coords:Vector2i) -> EnemyType:
	if !atlas_coords_to_enemy_type.has(atlas_coords):
		return 0
	return atlas_coords_to_enemy_type[atlas_coords]

func _get_atlas_coords(enemy_type:EnemyType) -> Vector2i:
	if !enemy_type_to_atlas_coords.has(enemy_type):
		return Vector2i.ZERO
	return enemy_type_to_atlas_coords[enemy_type]
