extends Node

func download_file(server_path: String, local_path: String) -> void:
    var http = HTTPRequest.new()
    http.download_file = local_path
    http.request(server_path)

func download_from_origin() -> int:
    var origin = GameManager.data_origin

    if origin.substr(0, 4) != "http":
        return 1
    
    

    return 0

func load_resource():
    pass
