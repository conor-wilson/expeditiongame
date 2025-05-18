class_name Player extends Node2D

@onready var player_character: Character = $PlayerCharacter

@export var map:Map
@export var enemies:Enemies
@export var sub_tick_timer:Timer

const PLAYER_ATLAS_COORDS:Vector2i = Vector2i(0,0)
const PLAYER_SOURCE_ID:int = 0

const TRIMMED_SAND_STEP_1:AudioStream = preload("res://assets/sfx/trimmed_sand_step_1.mp3")
const MAX_FOOTSTEP_PLAYERS:int = 6
var footstep_players:Array[AudioStreamPlayer] = []
var current_footstep_player_index:int = 0

func _ready() -> void:
	for i in range(MAX_FOOTSTEP_PLAYERS):
		var new_footstep_player = AudioStreamPlayer.new()
		new_footstep_player.stream = TRIMMED_SAND_STEP_1
		add_child(new_footstep_player)
		footstep_players.append(new_footstep_player)

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
	
	# Edge-case for when there's a dead enemy in front of the player
	var next_enemy:Character = enemies.get_enemy_at_coords(player_character.get_current_coords()+direction)
	if next_enemy != null && !next_enemy.alive:
		return false
	
	var walked:bool = player_character.walk(direction)
	
	if walked:
		play_footstep()
	
	return walked


func play_footstep():
	var footstep_player = footstep_players[current_footstep_player_index]
	footstep_player.stop()
	footstep_player.pitch_scale = randf_range(0.9, 1.1)
	footstep_player.play()
	current_footstep_player_index = (current_footstep_player_index + 1) % MAX_FOOTSTEP_PLAYERS

func get_current_coords() -> Vector2i:
	return player_character.get_current_coords()

func apply_wind():
	
	while true:
		if !map.tile_is_blowable_wind(player_character.get_current_coords()):
			return
			
		# Edge-case for when there's a dead enemy in front of the player
		var next_enemy:Character = enemies.get_enemy_at_coords(map.get_blown_to_coords_from_wind_tile(player_character.get_current_coords()))
		if next_enemy != null && !next_enemy.alive:
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
