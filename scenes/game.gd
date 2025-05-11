extends Node2D


func _ready() -> void:
	InventoryManager.connect("inventory_updated", _on_inventory_updated)
	
	$Levels/Level1.load()

func _on_inventory_updated():
	$Inventory.load_inventory()
