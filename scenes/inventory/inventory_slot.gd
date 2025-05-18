class_name InventorySlot extends Button

signal selected(InventorySlot)

# TODO: Synchronise the framerates of the sprites here and in the tilemaps

# The block that this slot contains
@export var block:Global.Block = Global.Block.EMPTY

@onready var blocks: MapTiles = $Blocks
@onready var highlight: AnimatedSprite2D = $Highlight


## SLOT SETTER FUNCS

func set_contents(new_block:Global.Block, amount:int):
	
	# Set the new contents
	block = new_block
	
	# Setup the visual behaviour
	show()
	blocks.set_block_tile(Vector2i(0,0), new_block)
	set_count(amount)

func set_count(amount:int):
	text = String.num_int64(amount)
	if !amount:
		hide()

# TODO: Create a custom focus texture for this


## SLOT GETTER FUNCS

func get_block() -> Global.Block:
	return block


## UI BEHAVIOUR FUNCS

func select():
	if block == Global.Block.EMPTY: return
	highlight.show()
	CursorManager.set_mouse_block_cursor(block)

func deselect():
	highlight.hide()

func _on_mouse_entered() -> void:
	grab_focus()

func _on_pressed() -> void:
	if block == Global.Block.EMPTY: return
	selected.emit(self)
