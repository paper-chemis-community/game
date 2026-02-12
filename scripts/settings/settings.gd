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
	$Tips.text = "提示：已开始下载，请勿关闭设置页面"
	var result: int = DownloadManager.download_from_origin()
	if result == 1:
		$Tips.text = "提示：下载失败。数据源路径错误"
		return
	elif result == 2:
		$Tips.text = "提示：下载失败。创建请求失败"
		return
	$Tips.text = "提示：正在加载资源，请勿关闭设置页面"
	DownloadManager.load_resource()
	$Tips.text = "提示：完成加载"
	
