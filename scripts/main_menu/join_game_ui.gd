extends Node2D


func _on_join_game_button_pressed() -> void:
	var ip: String = $JoinGameEdit.text
	MultiGame.create_client(ip)
	$".".hide()
	SceneManager.goto_scene("game")
