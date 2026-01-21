extends Node2D

func _ready() -> void:
	$DataSetting/LineEdit.text = GameManager.data_origin
	$IPBeginSetting/LineEdit.text = GameManager.ip_begin
	$UsernameSetting/LineEdit.text = GameManager.username

func _on_save_button_pressed() -> void:
	GameManager.data_origin = $DataSetting/LineEdit.text
	GameManager.ip_begin = $IPBeginSetting/LineEdit.text
	GameManager.username = $UsernameSetting/LineEdit.text
	SceneManager.goto_scene("main_menu")


func _on_cancel_button_pressed() -> void:
	SceneManager.goto_scene("main_menu")


func _on_download_button_pressed() -> void:
	pass # Replace with function body.
