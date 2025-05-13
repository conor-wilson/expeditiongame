class_name Level extends Node2D

signal phase_change(Phase)
signal win
signal loss
signal tick

# TODO: This is a very silly way to resolve the global position / local position issue. Fix this. 
const tile_global_position_offset:Vector2 = Vector2(32, 80)

const MIN_X:int = 0
const MIN_Y:int = 0
const MAX_X:int = 10
const MAX_Y:int = 10

const block_tilemap_coords:Dictionary = {
	Global.Block.EMPTY: Vector2i(-1,-1),
	Global.Block.WOOD:  Vector2i(0,0),
	Global.Block.STONE: Vector2i(0,1),
	Global.Block.WATER: Vector2i(0,2),
	Global.Block.FIRE:  Vector2i(0,3),
}

@export var block_tiles:TileMapLayer
@export var enemies:Array[Character]
@export var inventory:Array[Global.Block]
@export var player_start_position:Vector2i = Vector2i(5, 10)

var hovered_tile_coords:Vector2 = Vector2i(0,0)

enum Phase { DISABLED, PLAN, EXPLORE }
var phase:Phase


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
	$Player.reset(block_tiles)
	
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
	
	if block_tiles == null:
		push_error("tile clicked on level that has no block tiles")
	
	if _block_can_be_placed_on_cell(hovered_tile_coords):
		place_block(hovered_tile_coords)

func place_block(coords:Vector2i):
	if phase != Phase.PLAN: return
	
	block_tiles.set_cell(coords, 1, block_tilemap_coords[InventoryManager.get_selected_block()])
	InventoryManager.subtract_from_selected_block()
	$Inventory.refresh_inventory()
	
	if InventoryManager.inventory_is_empty():
		_start_explore_phase()

func _on_tile_hovered(button:TileButton):
	if phase != Phase.PLAN: return
	
	hovered_tile_coords = _get_map_tile_coords(button.global_position)
	
	$HoverGhosts.clear()
	if !InventoryManager.selected_block_is(Global.Block.EMPTY):
		$HoverGhosts.set_cell(hovered_tile_coords, 1, block_tilemap_coords[InventoryManager.get_selected_block()])

# _block_can_be_placed_on_cell returns true if the cell at the provided coordinates is empty 
# (checks Blocks layer).
func _block_can_be_placed_on_cell(coords : Vector2i) -> bool:
	if phase != Phase.PLAN: return false
	
	return (
		!InventoryManager.selected_block_is(Global.Block.EMPTY) &&
		block_tiles.get_cell_tile_data(coords) == null
		)

func _get_map_tile_coords(global_coords:Vector2) -> Vector2i:
	if phase != Phase.PLAN: return Vector2i.ZERO
	
	return block_tiles.local_to_map(global_coords - tile_global_position_offset)

func _on_inventory_focus_grabbed() -> void:
	if phase != Phase.PLAN: return
	
	hovered_tile_coords = Vector2i(-1,-1)
	$HoverGhosts.clear()

# TODO: Make this work
func _on_game_area_mouse_exited() -> void:
	if phase != Phase.PLAN: return
	
	hovered_tile_coords = Vector2i(-1,-1)
	$HoverGhosts.clear()


###################################
## EXPLORING PHASE FUNCTIONALITY ##
###################################

# TODO: Make it so that the player can move while holding the arrow key rather
# than only when the arrow key has just been pressed.

func _start_explore_phase():
	phase = Phase.EXPLORE
	$TileButtons.hide()
	print("STARTED EXPLORE PHASE!")
	phase_change.emit(phase)

func _input(event: InputEvent) -> void:
	if phase != Phase.EXPLORE: return
	
	var movement_direction:Vector2i = _event_to_direction_vector(event)
	if movement_direction:
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
	
	## Activate blocks
	_setup_block_coords()
	
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
			block_tiles.erase_cell(coords)
	
	# TODO: Add enemy death
	
	## Resolve player death
	if player_killed:
		loss.emit()
		disable()

func _setup_block_coords():
	for block_coords in block_tiles.get_used_cells():
		if block_tiles.get_cell_source_id(block_coords) == 1:
			var block_atlas_coords:Vector2i = block_tiles.get_cell_atlas_coords(block_coords)
			
			match block_atlas_coords:
				block_tilemap_coords[Global.Block.WATER]:
					water_block_coords[block_coords] = true
				block_tilemap_coords[Global.Block.FIRE]:
					fire_block_coords[block_coords] = true

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
	if _tile_is_floodable(coords):
		block_tiles.set_cell(coords, 1, block_tilemap_coords[Global.Block.WATER])
		fire_block_coords[coords] = null
		return coords == $Player.get_character_coords()
	return false

func _tile_is_floodable(coords:Vector2i) -> bool:
	return _tile_is_within_map(coords) && (
		block_tiles.get_cell_tile_data(coords) == null ||
		block_tiles.get_cell_atlas_coords(coords) == block_tilemap_coords[Global.Block.FIRE]
	)

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
	if _tile_is_burnable(coords):
		block_tiles.set_cell(coords, 1, block_tilemap_coords[Global.Block.FIRE])
		return coords == $Player.get_character_coords()
	return false

func _tile_is_burnable(coords:Vector2i) -> bool:
	return _tile_is_within_map(coords) && (
		coords == $Player.get_character_coords() ||
		block_tiles.get_cell_atlas_coords(coords) == block_tilemap_coords[Global.Block.WOOD]
	)


func _tile_is_within_map(coords:Vector2i) -> bool:
	
	return (
		coords.x > MIN_X && coords.y > MIN_Y &&
		coords.x < MAX_X && coords.y < MAX_Y
		)

func _on_player_win() -> void:
	disable()
	win.emit()
