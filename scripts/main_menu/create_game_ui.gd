extends Node2D

func _on_create_game_button_pressed() -> void:
	var player_num: int = int($CreateGameEdit.text)
	if 2 <= player_num and player_num <= 4:
		GameLoopManager.create_server(int(player_num))
		$".".hide()
		SceneManager.goto_scene("game/game")
	else:
		$Warn.show()


func _on_warn_button_pressed() -> void:
	$Warn.hide()
