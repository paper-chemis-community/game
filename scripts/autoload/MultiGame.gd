extends Node

var peer = ENetMultiplayerPeer.new()
var players: Array
var cards: Array
var player_num
var player_cards: Dictionary
var player_turns: Dictionary
var player_username: Dictionary
var player_hp: Dictionary

var server_round: int
var client_round: int

func add_player(id: int):
	if players.size() < player_num:
		players.append(id)

func create_server(playern: int) -> void:
	player_num = playern
	var error = peer.create_server(8989, playern)
	if error != OK:
		printerr(error)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func create_client(ip: String) -> void:
	peer.create_client(ip, 8989)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int) -> void:
	players.append(id)
	player_cards[id] = []

func _on_peer_disconnected(id: int) -> void:
	for i in range(players.size()):
		if players[i] == id:
			players.pop_at(i)
			player_cards.erase(id)
			break

func start_game() -> void:
	if players.size() != player_num:
		return
	deal_cards()
	server_round = 1

func extract() -> String:
	var index = randi() % cards.size()
	var card = cards[index]
	cards.pop_at(index)
	return card

func deal_cards() -> void:
	for i in range(player_num):
		player_cards[players[i]].append(extract())

func next_round() -> void:
	settle_round()
	server_round += 1

func settle_round() -> void:
	remote_variable()

@rpc
func begin_round() -> void:
	var id = multiplayer.get_remote_sender_id()
	if server_round == 1 and 0 <= player_turns[id] <= 1:
		for i in range(3):
			if player_cards[id].size() >= 8:
				break
			player_cards[id].append(extract())
	else:
		for i in range(4):
			if player_cards[id].size() >= 8:
				break
			player_cards[id].append(extract())

@rpc
func get_cards() -> Array:
	var sender_id = multiplayer.get_remote_sender_id()
	var data: Array = player_cards.get(sender_id, [-1])
	return data

func remote_variable() -> void:
	if not multiplayer.is_server():
		return
	var data: Dictionary = {}
	data["cards"] = cards
	data["player_cards"] = player_cards
	data["player_turns"] = player_turns
	data["player_hp"] = player_hp
	data["server_round"] = server_round

	get_remote_variable.rpc(data)

@rpc("authority", "call_remote", "reliable")
func get_remote_variable(data: Dictionary) -> void:
	cards = data["cards"]
	player_cards = data["player_cards"]
	player_turns = data["player_turns"]
	player_hp = data["player_hp"]
	server_round = data["server_round"]
