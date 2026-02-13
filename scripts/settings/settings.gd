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
	var options = $LoadSource/ChooseSource
	for source_name in GameManager.sources:
		options.add_item(source_name)

func _on_save_button_pressed() -> void:
	GameManager.data_origin = $DataSetting/LineEdit.text
	GameManager.ip_begin = $IPBeginSetting/LineEdit.text
	GameManager.username = $UsernameSetting/LineEdit.text
	GameManager.source = $LoadSource/ChooseSource.get_selected()
	SceneManager.goto_scene("main_menu")


func _on_cancel_button_pressed() -> void:
	SceneManager.goto_scene("main_menu")


func _on_download_button_pressed() -> void:
	$Tips.text = "提示：已开始下载，请勿关闭设置页面"
	var result: int = await DownloadManager.download_from_origin()
	if result == 1:
		$Tips.text = "提示：下载失败。数据源路径错误"
		return
	elif result == 2:
		$Tips.text = "提示：下载失败。创建请求失败"
		return
	$Tips.text = "提示：正在加载资源，请勿关闭设置页面"
	DownloadManager.load_resource()
	$Tips.text = "提示：完成加载"
	


func _on_load_button_pressed() -> void:
	DownloadManager.uuid = GameManager.sources[$LoadSource/ChooseSource.text]
	DownloadManager.load_resource()
	$Tips.text = "提示：完成加载"
