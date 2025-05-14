class_name Level extends Node2D

signal phase_change(Phase)
signal win
signal loss
signal tick

@export var enemies:Array[Character]
@export var inventory:Array[Global.Block]
@export var player_start_position:Vector2i = Vector2i(5, 10)

enum Phase { DISABLED, PLAN, EXPLORE }
var phase:Phase

@onready var map: Map = $Map


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
	$Player.start_position = player_start_position
	$Player.reset(map)
	
	# Disable everything
	disable()

func load():
	
	# TODO: Reset the layout of the map's tiles
	
	# Reset the inventory
	InventoryManager.set_inventory(inventory)
	$Inventory.refresh_inventory()
	
	# Reset the Player
	$Player.reset()
	
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
	$Inventory.grab_focus()
	print("STARTED PLAN PHASE!")
	phase_change.emit(phase)

func _on_tile_pressed() -> void:
	if phase != Phase.PLAN: return
	
	if map.attempt_to_place_hovered_tile(InventoryManager.get_selected_block()):
		InventoryManager.subtract_from_selected_block()
	
	$Inventory.refresh_inventory()
	if InventoryManager.inventory_is_empty():
		_start_explore_phase()

func _on_tile_hovered(button:TileButton):
	if phase != Phase.PLAN: return
	
	var coords:Vector2i = map.global_to_tile_coords(button.global_position)
	
	if !InventoryManager.selected_block_is(Global.Block.EMPTY):
		map.hover_tile(coords, InventoryManager.get_selected_block())

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
	if phase != Phase.EXPLORE: return
	
	var movement_direction:Vector2i = _event_to_direction_vector(event)
	if movement_direction:
		# TODO: First move the player, then call progress_one_tick. Let's separate these concepts.
		progress_one_tick(movement_direction)

func _event_to_direction_vector(event: InputEvent) -> Vector2i:
	if phase != Phase.EXPLORE: return Vector2i.ZERO
	
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

func progress_one_tick(movement_direction:Vector2i):
	
	## Move the Player
	var old_player_coords = $Player.get_character_coords()
	if !$Player.walk(movement_direction):
		print("Can't move player direction ", movement_direction)
		return
	
	## Delay by one tick (TODO: Make this a node, and prevent player movement while it's happening)
	await get_tree().create_timer(0.2).timeout
	
	## Move enemies
	var player_killed:bool
	for enemy in enemies:
		var direction_to_player:Vector2i = $Player.get_character_coords() - enemy.get_character_coords()
		enemy.walk(direction_to_player.clamp(Vector2i(-1,-1), Vector2i(1,1)))
		
		# Check to see if the player has been killed
		if enemy.get_character_coords() == $Player.get_character_coords():
			player_killed = true
	
	## Setup block coords arrays
	water_block_coords = map.get_block_tile_coords(Global.Block.WATER)
	fire_block_coords = map.get_block_tile_coords(Global.Block.FIRE)
	
	### Activate water blocks
	for coords in water_block_coords:
		if water_block_coords[coords]:
			if $Player.character_coords == coords: 
				player_killed = true
			if _flood_surrounding_tiles(coords):
				player_killed = true
	
	## Activate fire blocks
	for coords in fire_block_coords:
		if fire_block_coords[coords]:
			if $Player.character_coords == coords: 
				player_killed = true
			if _burn_surrounding_tiles(coords):
				player_killed = true
	
	# TODO: Add enemy death
	
	## Resolve player death
	if player_killed:
		loss.emit()
		disable()


# TODO: Maybe use inheritance here to make the below more generic

## WATER FUNCTIONALITY

func _flood_surrounding_tiles(coords:Vector2i) -> bool:
	
	var player_killed:bool = false
	
	if _flood_tile(coords+Vector2i.UP):
		player_killed = true
	if _flood_tile(coords+Vector2i.DOWN):
		player_killed = true
	if _flood_tile(coords+Vector2i.LEFT):
		player_killed = true
	if _flood_tile(coords+Vector2i.RIGHT):
		player_killed = true
		
	return player_killed

func _flood_tile(coords:Vector2i) -> bool:
	if map.tile_is_floodable(coords):
		map.place_block(coords, Global.Block.WATER)
		fire_block_coords[coords] = null
		return coords == $Player.get_character_coords()
	return false

## FIRE FUNCTIONALITY

func _burn_surrounding_tiles(coords:Vector2i) -> bool:
	
	var player_killed:bool = false
	
	if _burn_tile(coords+Vector2i.UP):
		player_killed = true
	if _burn_tile(coords+Vector2i.DOWN):
		player_killed = true
	if _burn_tile(coords+Vector2i.LEFT):
		player_killed = true
	if _burn_tile(coords+Vector2i.RIGHT):
		player_killed = true
		
	return player_killed

func _burn_tile(coords:Vector2i) -> bool:
	if map.tile_is_flamable(coords):
		map.place_block(coords, Global.Block.FIRE)
		return coords == $Player.get_character_coords()
	return false


func _on_player_win() -> void:
	disable()
	win.emit()
