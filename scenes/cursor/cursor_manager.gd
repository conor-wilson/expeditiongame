extends Node

@onready var EMPTY_CURSOR:Resource = preload("res://assets/art/cursors/EmptyCursor.png")
@onready var WOOD_BLOCK_CURSOR = preload("res://assets/art/cursors/WoodBlockCursor.png")
@onready var STONE_BLOCK_CURSOR = preload("res://assets/art/cursors/StoneBlockCursor.png")
@onready var WATER_BLOCK_CURSOR = preload("res://assets/art/cursors/WaterBlockCursor.png")
@onready var FIRE_BLOCK_CURSOR = preload("res://assets/art/cursors/FireBlockCursor.png")

@onready var cursor_hotspots:Dictionary = {
	EMPTY_CURSOR:       Vector2.ZERO,
	WOOD_BLOCK_CURSOR:  Vector2.ZERO,
	STONE_BLOCK_CURSOR: Vector2.ZERO,
	WATER_BLOCK_CURSOR: Vector2.ZERO,
	FIRE_BLOCK_CURSOR:  Vector2.ZERO,
}

var current_cursor:Resource

@onready var block_cursors:Dictionary = {
	Global.Block.EMPTY: EMPTY_CURSOR,
	Global.Block.WOOD:  WOOD_BLOCK_CURSOR,
	Global.Block.STONE: STONE_BLOCK_CURSOR,
	Global.Block.WATER: WATER_BLOCK_CURSOR,
	Global.Block.FIRE:  FIRE_BLOCK_CURSOR,
}

func _ready() -> void:
	set_mouse_cursor(EMPTY_CURSOR)

func set_mouse_cursor(source:Resource):
	Input.set_custom_mouse_cursor(source, Input.CURSOR_ARROW, cursor_hotspots[source])
	current_cursor = source
	
func set_mouse_block_cursor(block:Global.Block):
	var source:Resource = block_cursors[block]
	Input.set_custom_mouse_cursor(source, Input.CURSOR_ARROW, cursor_hotspots[source])
	current_cursor = source

func current_cursor_is(source:Resource) -> bool:
	return current_cursor == source
