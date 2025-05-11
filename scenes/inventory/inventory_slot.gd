class_name InventorySlot extends Button

signal selected

# The block that this slot contains
@export var block:Global.Block = Global.Block.EMPTY
@export var starting_count:int = 1

@onready var block_sprites = {
	Global.Block.WOOD:  $Sprites/WoodSprite,
	Global.Block.STONE: $Sprites/StoneSprite,
	Global.Block.WATER: $Sprites/WaterSprite,
	Global.Block.FIRE:  $Sprites/FireSprite,
}

func _ready() -> void:
	_set_sprite()
	_set_count(starting_count)

func set_contents(new_block:Global.Block, amount:int):
	
	# Set the new contents
	block = new_block
	
	# Setup the visual behaviour
	show()
	_set_sprite()
	_set_count(amount)


func _set_sprite():
	
	if block == Global.Block.EMPTY:
		hide()
		return
	
	for sprite in $Sprites.get_children():
		sprite.hide()
	block_sprites[block].show()

func _set_count(amount:int):
	
	if !amount:
		hide()
		return
	
	$Count.text = String.num_int64(amount)

# TODO: Create a custom focus texture for this

func check_selected():
	if InventoryManager.selected_block_is(block):
		show_selected()
	else:
		show_deselected()

func show_selected():
	if block == Global.Block.EMPTY: return
	$Highlight.show()

func show_deselected():
	$Highlight.hide()

func _on_mouse_entered() -> void:
	#hovered.emit(self)
	grab_focus()

func _on_mouse_exited() -> void:
	if InventoryManager.selected_block != block:
		check_selected()

func _on_pressed() -> void:
	if block == Global.Block.EMPTY: return
	
	print("BLOCK CLICKED: ", block)
	InventoryManager.set_selected_block(block)
	CursorManager.set_mouse_block_cursor(block)
	check_selected()
	selected.emit()
