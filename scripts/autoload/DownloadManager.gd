extends Node

func _ready() -> void:
	print(OS.get_user_data_dir())

func create_file(file_path: String) -> void:
	var base_dir = file_path.get_base_dir()
	if !DirAccess.dir_exists_absolute(base_dir):
		DirAccess.make_dir_recursive_absolute(base_dir)
	FileAccess.open(file_path, FileAccess.WRITE)

func download_file(server_path: String, local_path: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var file_path = "user://downloads_test/" + local_path
	if !FileAccess.file_exists(file_path):
		create_file(file_path)
	http.set_download_file(file_path)
	http.request(server_path)

func download_from_origin() -> int:
	var origin = GameManager.data_origin
	var http = HTTPRequest.new()
	add_child(http)

	if origin.substr(0, 4) != "http":
		return 1
	
	if http.request(origin) != OK:
		return 2

	if origin[-1] != "/":
		origin = origin + "/"

	download_file(origin + "card/id/Oxygen", "test_Oxygen.json")

	return 0

func load_resource():
	pass
