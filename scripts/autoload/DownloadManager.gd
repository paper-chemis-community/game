extends Node

@onready var http_request = $HTTPRequest

# 下载文件
func download_file(url: String, filename: String):
    # 构建保存路径
    var save_path = "user://" + filename
    print("开始下载: ", url)
    print("保存到: ", save_path)
    
    # 发送请求
    var error = http_request.request(url)
    if error != OK:
        push_error("请求发送失败: " + str(error))
        return false
    
    # 连接信号（一次性）
    if http_request.is_connected("request_completed", _on_request_completed):
        http_request.request_completed.disconnect(_on_request_completed)
    
    http_request.request_completed.connect(_on_request_completed.bind(save_path), CONNECT_ONE_SHOT)
    
    return true

# 请求完成回调
func _on_request_completed(result, response_code, headers, body, save_path):
    if result != HTTPRequest.RESULT_SUCCESS:
        push_error("下载失败，错误代码: " + str(result))
        return
    
    if response_code != 200:
        push_error("HTTP错误: " + str(response_code))
        return
    
    # 保存文件
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        push_error("无法创建文件: " + save_path)
        push_error("错误: " + str(FileAccess.get_open_error()))
        return
    
    file.store_buffer(body)
    file.close()
    
    print("文件保存成功: " + save_path)
    print("文件大小: " + str(body.size()) + " 字节")

func download_from_origin() -> void:
    if GameManager.data_origin.substr(0, 4) != "http":
        return
    
    
