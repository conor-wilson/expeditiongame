class_name Game extends Node2D

signal main_menu

@onready var levels: Node2D = $Levels

func _ready() -> void:
	disable_all_levels()
	hide_menus()

func disable_all_levels():
	for level in levels.get_children():
		if level is Level:
			level.hide()
			level.disable()

func load_level(num:int):
	disable_all_levels()
	hide_menus()
	var level = levels.get_child(num-1)
	if level is Level:
		level.show()
		level.load()

func hide_menus():
	$WinMenu.hide()
	$LoseMenu.hide()

# TODO: Either change the way this is done, or apply the same methodology to the Inventory.
func _on_level_1_phase_change(Phase: Variant) -> void:
	if Phase == Level.Phase.PLAN:
		$PhaseLabel.text = "PLAN YOUR\nEXPEDITION"
	elif Phase == Level.Phase.EXPLORE:
		$PhaseLabel.text = "EXPLORE!"


# TODO: Same here?
func _on_level_1_win() -> void:
	await get_tree().create_timer(0.5).timeout
	$WinMenu.show()


# TODO: Same here?
func _on_level_1_loss() -> void:
	await get_tree().create_timer(0.5).timeout
	$LoseMenu.show()


func _on_menu_button_pressed() -> void:
	main_menu.emit()


func _on_reset_button_pressed() -> void:
	$Levels/Level1.load()
	hide_menus()
	
