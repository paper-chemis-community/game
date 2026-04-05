extends Node

var game_round: int = -1

signal end_game

func _ready() -> void:
	end_game.connect(_on_end_game)

func start_game() -> void:
	game_round = 1

func settle_round() -> void:
	game_round += 1
	if check_game_end():
		end_game.emit()

func check_game_end() -> bool:
	return false

func _on_end_game() -> void:
	game_round = -1
