class_name InventorySlot extends Area2D

signal selected

# The block that this slot contains
@export var block:Global.Block = Global.Block.EMPTY
#@export var amount:int = 1

@onready var block_sprites = {
	Global.Block.WOOD:  $Sprites/WoodSprite,
	Global.Block.STONE: $Sprites/StoneSprite,
	Global.Block.WATER: $Sprites/WaterSprite,
	Global.Block.FIRE:  $Sprites/FireSprite,
}

func _ready() -> void:
	_set_sprite()

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

# TODO: Maybe distinguish between the look of a hovered block vs a selected
# block by adding distinct functionality to the below functions.

func check_selected():
	if InventoryManager.selected_block_is(block):
		show_selected()
	else:
		show_deselected()
		show_not_hovering()

func show_hovering():
	if block == Global.Block.EMPTY: return
	$Highlight.show()

func show_not_hovering():
	$Highlight.hide()

func show_selected():
	if block == Global.Block.EMPTY: return
	$Highlight.show()

func show_deselected():
	$Highlight.hide()

func _on_mouse_entered() -> void:
	show_hovering()

func _on_mouse_exited() -> void:
	if InventoryManager.selected_block != block:
		check_selected()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if block == Global.Block.EMPTY: return
	
	if event.is_action_pressed("click"):
		print("BLOCK CLICKED: ", block)
		InventoryManager.set_selected_block(block)
		CursorManager.set_mouse_block_cursor(block)
		check_selected()
		selected.emit()
