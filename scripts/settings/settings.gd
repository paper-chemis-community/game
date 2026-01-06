extends Node2D

func _ready() -> void:
	$DataSetting/LineEdit.text = GameManager.data_origin
	$IPBeginSetting/LineEdit.text = GameManager.ip_begin

func _on_save_button_pressed() -> void:
	GameManager.data_origin = $DataSetting/LineEdit.text
	GameManager.ip_begin = $IPBeginSetting/LineEdit.text
	SceneManager.goto_scene("main_menu")


func _on_cancel_button_pressed() -> void:
	SceneManager.goto_scene("main_menu")
