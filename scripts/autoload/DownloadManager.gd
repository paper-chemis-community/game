extends Node

var uuid: String = "source"

func create_file(file_path: String) -> void:
	var base_dir = file_path.get_base_dir()
	if !DirAccess.dir_exists_absolute(base_dir):
		DirAccess.make_dir_recursive_absolute(base_dir)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.close()

func download_file(server_path: String, local_path: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var file_path = local_path
	if !FileAccess.file_exists(file_path):
		create_file(file_path)
	http.download_file = file_path
	http.request(server_path)
	await http.request_completed

func get_uuid() -> void:
	var index_file = FileAccess.open("user://download/temp/index.json", FileAccess.READ)
	var index_text = index_file.get_as_text()
	var content = JSON.parse_string(index_text)
	index_file.close()
	uuid = content["uuid"]

func download_defs(type: String, origin: String) -> void:
	var list_file = FileAccess.open("user://download/%s/%ss/list.json" % [uuid, type], FileAccess.READ)
	var list_text = list_file.get_as_text()
	var list = JSON.parse_string(list_text)
	list_file.close()
	if !list:
		return
	for k in list:
		var filename = list[k]
		await download_file("%s%s/id/%s" % [origin, type, k], "user://download/%s/%ss/%s.json" % [uuid, type, filename])

func download_assets(origin: String) -> void:
	var list_file = FileAccess.open("user://download/%s/assets/list.json" % [uuid], FileAccess.READ)
	var list_text = list_file.get_as_text()
	var list = JSON.parse_string(list_text)
	list_file.close()
	if !list:
		return
	for k in list["pics"]:
		var filename = list["pics"][k]
		await download_file("%sasset/pic/%s" % [origin, k], "user://download/%s/assets/pics/%s" % [uuid, filename])
	for k in list["sounds"]:
		var filename = list["sounds"][k]
		await download_file("%sasset/sound/%s" % [origin, k], "user://download/%s/assets/sounds/%s" % [uuid, filename])

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

	await download_file(origin + "index", "user://download/temp/index.json")

	get_uuid()

	await download_file(origin + "card/list", "user://download/%s/cards/list.json" % [uuid])
	await download_file(origin + "reaction/list", "user://download/%s/reactions/list.json" % [uuid])
	await download_file(origin + "matter/list", "user://download/%s/matters/list.json" % [uuid])
	await download_file(origin + "asset/list", "user://download/%s/assets/list.json" % [uuid])
	
	await download_defs("card", origin)
	await download_defs("reaction", origin)
	await download_defs("matter", origin)
	
	await download_assets(origin)

	return 0

func load_resource():
	var card_file = FileAccess.open("user://download/%s/cards/list.json" % [uuid], FileAccess.READ)
	GameManager.card_list = JSON.parse_string(card_file.get_as_text())
	card_file.close()

	var reaction_file = FileAccess.open("user://download/%s/reactions/list.json" % [uuid], FileAccess.READ)
	GameManager.reaction_list = JSON.parse_string(reaction_file.get_as_text())
	reaction_file.close()

	var matter_file = FileAccess.open("user://download/%s/matters/list.json" % [uuid], FileAccess.READ)
	GameManager.matter_list = JSON.parse_string(matter_file.get_as_text())
	matter_file.close()

	var asset_file = FileAccess.open("user://download/%s/assets/list.json" % [uuid], FileAccess.READ)
	var asset_list = JSON.parse_string(asset_file.get_as_text())
	GameManager.pic_list = asset_list["pics"]
	GameManager.sound_list = asset_list["sounds"]
	asset_file.close()
