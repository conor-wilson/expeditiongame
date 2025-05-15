class_name Level extends Node2D

signal phase_change(Phase)
signal win
signal loss
signal tick

@export var blocks_config:MapTiles
@export var markers_config:MapTiles
@export var background_config:MapTiles
@export var inventory_config:Array[Global.Block]

@export var player_start_position:Vector2i = Vector2i(5, 10) # TODO: Maybe use a marker here to make it easier to do visually?
@export var enemies:Array[Enemy]

enum Phase { DISABLED, PLAN, EXPLORE }
var phase:Phase

@onready var map: Map = $Map
@onready var player: Character = $Player
@onready var inventory: Inventory = $Inventory
@onready var sub_tick_timer: Timer = $SubTickTimer

var tick_is_occurring:bool = false

##########################
## BOOTUP FUNCTIONALITY ##
##########################

func _ready() -> void:
	
	# Connect everything
	for row in $TileButtons.get_children():
		for tile in row.get_children():
			if tile is TileButton:
				tile.connect("pressed", _on_tile_pressed)
				tile.connect("hovered", _on_tile_hovered)
	
	# Initialise everything
	player.start_position = player_start_position
	player.reset()
	for enemy in enemies:
		enemy.set_map(map)
		enemy.reset()
	
	# Disable everything
	disable()

func load():
	
	# Reset the map
	map.reset(blocks_config, markers_config, background_config)
	
	# Reset the inventory
	inventory.set_inventory_dict_from_array(inventory_config)
	
	# Reset the Player
	player.reset()
	
	# Reset the Enemies
	for enemy in enemies:
		enemy.reset()
	
	# Start the Planning Phase
	_start_planning_phase()

func disable():
	phase = Phase.DISABLED
	$TileButtons.hide()


##################################
## PLANNING PHASE FUNCTIONALITY ##
##################################

# TODO: Do some stuff with focus grabbing when resources run out

func _start_planning_phase():
	phase = Phase.PLAN
	$TileButtons.show()
	inventory.grab_focus()
	print("STARTED PLAN PHASE!")
	phase_change.emit(phase)

func _on_tile_pressed() -> void:
	if phase != Phase.PLAN: return
	
	if map.attempt_to_place_hovered_tile(inventory.get_selected_block()):
		inventory.subtract_from_selected_block()
	
	if inventory.is_empty():
		_start_explore_phase()

func _on_tile_hovered(button:TileButton):
	if phase != Phase.PLAN: return
	
	var coords:Vector2i = map.global_to_tile_coords(button.global_position)
	
	if !inventory.selected_block_is(Global.Block.EMPTY):
		map.hover_tile(coords, inventory.get_selected_block())

func _on_inventory_focus_grabbed() -> void:
	if phase != Phase.PLAN: return
	
	map.stop_hovering()

# TODO: Make this work
func _on_game_area_mouse_exited() -> void:
	if phase != Phase.PLAN: return
	
	map.stop_hovering()


###################################
## EXPLORING PHASE FUNCTIONALITY ##
###################################

# TODO: Make it so that the player can move while holding the arrow key rather
# than only when the arrow key has just been pressed.

func _start_explore_phase():
	phase = Phase.EXPLORE
	$TileButtons.hide()
	map.stop_hovering()
	print("STARTED EXPLORE PHASE!")
	phase_change.emit(phase)

func _input(event: InputEvent) -> void:
	if phase != Phase.EXPLORE || tick_is_occurring: 
		return
	
	var direction:Vector2i = _event_to_direction_vector(event)
	if direction && player.walk(direction):
		if !_check_player_death():
			progress_one_tick()

func _event_to_direction_vector(event: InputEvent) -> Vector2i:
	if event.is_action_pressed("up"):
		return Vector2i.UP
	elif event.is_action_pressed("down"):
		return Vector2i.DOWN
	elif event.is_action_pressed("left"):
		return Vector2i.LEFT
	elif event.is_action_pressed("right"):
		return Vector2i.RIGHT
	
	return Vector2i.ZERO

var water_block_coords:Dictionary = {}
var fire_block_coords:Dictionary = {} 

func progress_one_tick():
	
	# Start the tick
	if phase != Phase.EXPLORE || tick_is_occurring: 
		return
	tick_is_occurring = true
	
	## Wait one sub-tick
	sub_tick_timer.start()
	await sub_tick_timer.timeout
	
	## Move enemies
	for enemy in enemies:
		enemy.follow_player(player.get_current_coords())
	
	## Setup block coords arrays
	water_block_coords = map.get_block_tile_coords(Global.Block.WATER)
	fire_block_coords = map.get_block_tile_coords(Global.Block.FIRE)
	
	## Wait one sub-tick
	sub_tick_timer.start()
	await sub_tick_timer.timeout
	
	## Activate fire blocks
	for coords in fire_block_coords:
		if fire_block_coords[coords]:
			_burn_surrounding_tiles(coords)
	
	## Wait one sub-tick
	sub_tick_timer.start()
	await sub_tick_timer.timeout
	
	### Activate water blocks
	for coords in water_block_coords:
		if water_block_coords[coords]:
			_flood_surrounding_tiles(coords)
	
	## Wait one sub-tick
	sub_tick_timer.start()
	await sub_tick_timer.timeout
	
	# TODO: Add enemy death
	for enemy in enemies:
		if map.tile_is_deadly(enemy.get_current_coords()):
			enemy.kill()
	
	## Resolve player win or loss
	if !_check_player_death():
		_check_player_win()
	
	tick_is_occurring = false

func _wait_one_sub_tick():
	sub_tick_timer.start()
	await sub_tick_timer.timeout

## WATER FUNCTIONALITY

func _flood_surrounding_tiles(coords:Vector2i):
	_flood_tile(coords+Vector2i.UP)
	_flood_tile(coords+Vector2i.DOWN)
	_flood_tile(coords+Vector2i.LEFT)
	_flood_tile(coords+Vector2i.RIGHT)

func _flood_tile(coords:Vector2i):
	if map.tile_is_floodable(coords):
		map.place_block(coords, Global.Block.WATER)
		fire_block_coords[coords] = null

## FIRE FUNCTIONALITY

func _burn_surrounding_tiles(coords:Vector2i):
	_burn_tile(coords+Vector2i.UP)
	_burn_tile(coords+Vector2i.DOWN)
	_burn_tile(coords+Vector2i.LEFT)
	_burn_tile(coords+Vector2i.RIGHT)

func _burn_tile(coords:Vector2i):
	if map.tile_is_flamable(coords):
		map.place_block(coords, Global.Block.FIRE)

func _check_player_death() -> bool:
	
	var player_killed:bool = false
	
	# Check for deadly block tiles
	if map.tile_is_deadly(player.get_current_coords()):
		player_killed = true
	
	# Check for enemies
	for enemy in enemies:
		if enemy.get_current_coords() == player.get_current_coords():
			player_killed = true
	
	# Kill the playewr
	if player_killed:
		player.kill()
		loss.emit()
		disable()
	return player_killed

func _check_player_win() -> bool:
	if map.tile_is_exit(player.get_current_coords()):
		win.emit()
		disable()
		return true
	return false
