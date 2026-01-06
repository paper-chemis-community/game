extends Node2D

func _ready() -> void:
	$DataSetting/LineEdit.text = GameManager.data_origin

func _on_save_button_pressed() -> void:
	GameManager.data_origin = $DataSetting/LineEdit.text
	SceneManager.goto_scene("main_menu")


func _on_cancel_button_pressed() -> void:
	SceneManager.goto_scene("main_menu")
