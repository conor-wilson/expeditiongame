class_name Player extends Node2D

@onready var player_character: Character = $PlayerCharacter

@export var map:Map
@export var enemies:Enemies
@export var sub_tick_timer:Timer

const PLAYER_ATLAS_COORDS:Vector2i = Vector2i(0,0)
const PLAYER_SOURCE_ID:int = 0


func reset(player_config:TileMapLayer = null) -> void:
	clear_player_character()
	
	if player_config != null:
		copy_player_character_from_config(player_config)

func clear_player_character():
	player_character.kill()
	player_character.teleport(Vector2i(-1,-1))
	player_character.clear()

func copy_player_character_from_config(player_config:TileMapLayer) -> void:
	
	var used_cells:Array[Vector2i] = player_config.get_used_cells()
	if len(used_cells) != 1:
		push_error("player config has an incorrect amount of used cells: ", len(used_cells))
	else:
		player_character.tilemap_atlas_coords = PLAYER_ATLAS_COORDS
		player_character.tilemap_source = PLAYER_SOURCE_ID
		player_character.start_position = used_cells[0]
		player_character.set_map(map)
		player_character.reset()
	
	player_config.hide()

func walk(direction:Vector2i) -> bool:
	return player_character.walk(direction)

func get_current_coords() -> Vector2i:
	return player_character.get_current_coords()

func apply_wind():
	
	while true:
		if !map.tile_is_blowable_wind(player_character.get_current_coords()):
			return
		
		check_death()
		
		## Wait one sub-tick
		sub_tick_timer.start()
		await sub_tick_timer.timeout
		
		player_character.teleport(map.get_blown_to_coords_from_wind_tile(player_character.get_current_coords()))

func check_death() -> bool:
	
	if !player_character.alive:
		return true
	
	# Check for deadly block tiles
	if map.tile_is_deadly(player_character.get_current_coords()):
		player_character.kill()
		return true
	
	# Check for enemies
	if enemies.tile_contains_enemy(player_character.get_current_coords()):
		player_character.kill()
		return true
	
	return false

func check_win() -> bool:
	return map.tile_is_exit(player_character.get_current_coords())
