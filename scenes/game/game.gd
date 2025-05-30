class_name Game extends Node2D

signal main_menu
signal level_select
signal level_won(level:int)

@onready var levels: Node2D = $Levels
@onready var spare_levels: Node2D = $SpareLevels

var current_level:int = 1

var loss_menu_active:bool = false
var win_menu_active:bool = false

func _ready() -> void:
	disable_all_levels()
	disable_spare_levels()
	hide_menus()
	
	for level in levels.get_children():
		if level is Level:
			level.loss.connect(_on_level_loss)
			level.phase_change.connect(_on_level_phase_change)
			level.win.connect(_on_level_win)
	
	loss_menu_active = false
	win_menu_active = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		load_level(current_level)
	if Input.is_action_just_pressed("pause"):
		CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
		main_menu.emit()
	
	if Input.is_action_just_pressed("hide_menu"):
		if loss_menu_active:
			$LossMenu.hide()
		if win_menu_active:
			$WinMenu.hide()
	if Input.is_action_just_released("hide_menu"):
		if loss_menu_active:
			$LossMenu.show()
		if win_menu_active:
			$WinMenu.show()

func disable_all_levels():
	for level in levels.get_children():
		if level is Level:
			level.hide()
			level.disable()

func disable_spare_levels():
	for level in spare_levels.get_children():
		if level is Level:
			level.hide()
			level.disable()


func load_level(num:int):
	current_level = num
	disable_all_levels()
	hide_menus()
	var level = levels.get_child(num-1)
	if level is Level:
		level.show()
		level.load()
	loss_menu_active = false
	win_menu_active = false
	
	if num == 1:
		$Levels/Level1/Hint1.show()
		$Levels/Level1/Hint2.show()
		$Levels/Level1/Hint3.hide()

func hide_menus():
	$WinMenu.hide()
	$LossMenu.hide()
	# TODO: I probably only need to do this here instead of the overkill of having it everywhere
	loss_menu_active = false
	win_menu_active = false

func _on_level_phase_change(Phase: Variant) -> void:
	if Phase == Level.Phase.PLAN:
		$PhaseLabel.text = "PLAN"
	elif Phase == Level.Phase.EXPLORE:
		$PhaseLabel.text = "EXPLORE"
		
		if current_level == 1:
			$Levels/Level1/Hint1.hide()
			$Levels/Level1/Hint2.hide()
			$Levels/Level1/Hint3.show()


func _on_level_win() -> void:
	print("LEVEL ", current_level, " WON")
	await get_tree().create_timer(0.5).timeout
	$WinMenu.show()
	loss_menu_active = false
	win_menu_active = true
	level_won.emit(current_level)

func _on_level_loss() -> void:
	$DeathNoise.pitch_scale = randf_range(0.9, 1.1)
	$DeathNoise.play()
	print("LEVEL ", current_level, " LOST")
	await get_tree().create_timer(0.5).timeout
	$LossMenu.show()
	CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	loss_menu_active = true
	win_menu_active  = false


func _on_level_select_button_pressed() -> void:
	level_select.emit()
	CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	loss_menu_active = false
	win_menu_active  = false

func _on_reset_button_pressed() -> void:
	load_level(current_level)
	hide_menus()
	CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	loss_menu_active = false
	win_menu_active  = false

func _on_menu_button_pressed() -> void:
	main_menu.emit()
	CursorManager.set_mouse_block_cursor(Global.Block.EMPTY)
	loss_menu_active = false
	win_menu_active  = false
