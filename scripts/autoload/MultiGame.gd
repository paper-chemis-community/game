extends Node

var peer = ENetMultiplayerPeer.new()

var players: Array
var cards: Array
var my_card: Array
var max_players: int
var player_cards: Dictionary
var player_turns: Dictionary
var player_username: Dictionary
var player_hp: Dictionary

var server_round: int
var client_round: int

func add_player(id: int):
	if players.size() < max_players:
		players.append(id)
		player_cards[id] = []

func remove_player(id: int):
	for i in range(players.size()):
		if players[i] == id:
			players.pop_at(i)
			player_cards.erase(id)
			break

func create_server(playern: int) -> void:
	max_players = playern
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
	add_player(id)

func _on_peer_disconnected(id: int) -> void:
	remove_player(id)

func start_game() -> void:
	if players.size() != max_players:
		return
	deal_cards()
	server_round = 1
	remote_variable()

func extract() -> String:
	if cards.size() == 0:
		return ""
	var index = randi() % cards.size()
	var card = cards[index]
	cards.pop_at(index)
	return card

func deal_cards() -> void:
	for player in players:
		while player_cards[player].size() < 8:
			var card = extract()
			if card != "":
				player_cards[player].append(card)

func next_round() -> void:
	settle_round()
	server_round += 1

func settle_round() -> void:
	for player in players:
		request_card_draw(player)
	remote_variable()

func request_card_draw(player_id: int) -> void:
	if server_round == 1 and 0 <= player_turns[player_id] <= 1:
		for i in range(3):
			if player_cards[player_id].size() >= 8:
				break
			var card = extract()
			if card != "":
				player_cards[player_id].append(card)
	else:
		for i in range(4):
			if player_cards[player_id].size() >= 8:
				break
			var card = extract()
			if card != "":
				player_cards[player_id].append(card)
	remote_variable()

func get_my_cards() -> void:
	request_cards.rpc()

@rpc("any_peer", "call_remote", "reliable")
func request_cards() -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var data: Array = player_cards.get(sender_id, [-1])
	send_cards.rpc_id(sender_id, data)

@rpc("authority", "call_remote", "reliable")
func send_cards(data: Array) -> void:
	my_card = data

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
