extends Node2D

@onready var game: Game = $Game
@onready var main_menu: ColorRect = $MainMenu

func _ready() -> void:
	_show_main_menu()

func _show_main_menu():
	main_menu.show()

func _close_main_menu():
	main_menu.hide()

func _on_game_main_menu() -> void:
	_show_main_menu()


func _on_level_1_pressed() -> void:
	game.load_level(1)
	_close_main_menu()

func _on_level_2_pressed() -> void:
	game.load_level(2)
	_close_main_menu()

func _on_level_3_pressed() -> void:
	game.load_level(3)
	_close_main_menu()

func _on_level_4_pressed() -> void:
	game.load_level(4)
	_close_main_menu()

func _on_level_5_pressed() -> void:
	game.load_level(5)
	_close_main_menu()

func _on_level_6_pressed() -> void:
	game.load_level(6)
	_close_main_menu()

func _on_level_7_pressed() -> void:
	game.load_level(7)
	_close_main_menu()

func _on_level_8_pressed() -> void:
	game.load_level(8)
	_close_main_menu()

func _on_level_9_pressed() -> void:
	game.load_level(9)
	_close_main_menu()

func _on_level_10_pressed() -> void:
	game.load_level(10)
	_close_main_menu()

func _on_level_11_pressed() -> void:
	game.load_level(11)
	_close_main_menu()

func _on_level_12_pressed() -> void:
	game.load_level(12)
	_close_main_menu()

func _on_level_13_pressed() -> void:
	game.load_level(13)
	_close_main_menu()

func _on_level_14_pressed() -> void:
	game.load_level(14)
	_close_main_menu()

func _on_level_15_pressed() -> void:
	game.load_level(15)
	_close_main_menu()
