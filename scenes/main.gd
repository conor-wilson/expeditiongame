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
