extends Node

func download_file(server_path: String, local_path: String) -> void:
    var http = HTTPRequest.new()
    http.download_file = local_path
    http.request(server_path)

func download_from_origin() -> int:
    var origin = GameManager.data_origin
    var http = HTTPRequest.new()

    if origin.substr(0, 4) != "http":
        return 1
    
    if http.request(origin) != OK:
        return 2

    if origin[-1] != "/":
        origin = origin + "/"

    return 0

func load_resource():
    pass
