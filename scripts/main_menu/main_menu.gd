extends Node2D


func _on_join_game_pressed() -> void:
	$JoinGameUI.show()

func _on_start_game_pressed() -> void:
	$CreateGameUI.show()
