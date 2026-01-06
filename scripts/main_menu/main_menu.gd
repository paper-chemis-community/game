extends Node2D


func _on_join_game_pressed() -> void:
	$JoinGameUI.show()

func _on_start_game_pressed() -> void:
	$CreateGameUI.show()


func _on_setting_button_pressed() -> void:
	SceneManager.goto_scene("settings")
