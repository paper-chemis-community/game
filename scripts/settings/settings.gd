extends Node2D

func _ready() -> void:
	init_sources()
	init_text()

func init_text() -> void:
	$DataSetting/LineEdit.text = GameManager.data_origin
	$IPBeginSetting/LineEdit.text = GameManager.ip_begin
	$UsernameSetting/LineEdit.text = GameManager.username
	$LoadSource/ChooseSource.select(GameManager.source)

func init_sources() -> void:
	DownloadManager.get_sources()
	for source_name in GameManager.sources:
		$LoadSource/ChooseSource.add_item(source_name)

func _on_save_button_pressed() -> void:
	GameManager.data_origin = $DataSetting/LineEdit.text
	GameManager.ip_begin = $IPBeginSetting/LineEdit.text
	GameManager.username = $UsernameSetting/LineEdit.text
	GameManager.source = $LoadSource/ChooseSource.get_selected()
	TranslationServer.set_locale($ChooseLanguage/ChooseLanguage.text)
	$Tips.text = "SETTINGS_TIP_SAVESETTINGS"


func _on_cancel_button_pressed() -> void:
	SceneManager.goto_scene("menus/main_menu")


func _on_download_button_pressed() -> void:
	$Tips.text = "SETTINGS_TIP_STARTDOWNLOAD"
	var result: int = await DownloadManager.download_from_origin()
	if result == 1:
		$Tips.text = "SETTINGS_TIP_SOURCEERROR"
		return
	elif result == 2:
		$Tips.text = "SETTINGS_TIP_REQUESTERROR"
		return
	$Tips.text = "SETTINGS_TIP_LOADING"
	DownloadManager.load_resource()
	$Tips.text = "SETTINGS_TIP_LOADED"
	


func _on_load_button_pressed() -> void:
	if GameManager.sources.size() == 0 or GameManager.source == -1:
		$Tips.text = "SETTINGS_TIP_NOLOCALSOURCE"
		return;
	DownloadManager.uuid = GameManager.sources[$LoadSource/ChooseSource.text]
	DownloadManager.load_resource()
	$Tips.text = "SETTINGS_TIP_LOADED"
