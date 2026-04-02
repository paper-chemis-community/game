extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var players: Array[int] = []
var max_players: int = 0
var player_cards: Dictionary = {}
var player_turns: Dictionary = {}
var player_username: Dictionary = {}
var player_hp: Dictionary = {}

var cards: Array[String] = []
var my_card: Array[String] = []

var server_round: int = 0
var client_round: int = 0
var game_started: bool = false

func add_player(id: int) -> void:
	if players.size() < max_players and not players.has(id):
		players.append(id)
		player_cards[id] = []
		if not player_turns.has(id):
			player_turns[id] = 0
		if not player_hp.has(id):
			player_hp[id] = 100

func remove_player(id: int) -> void:
	var index = players.find(id)
	if index != -1:
		players.remove_at(index)
		player_cards.erase(id)
		player_turns.erase(id)
		player_hp.erase(id)
		player_username.erase(id)

func create_server(playern: int) -> void:
	max_players = playern
	var error = peer.create_server(8989, playern)
	if error != OK:
		push_error("Failed to create server: " + str(error))
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	add_player(1)

func create_client(ip: String) -> void:
	var error = peer.create_client(ip, 8989)
	if error != OK:
		push_error("Failed to create client: " + str(error))
		return
	
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int) -> void:
	print("Player connected: ", id)
	add_player(id)
	sync_players.rpc()

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected: ", id)
	remove_player(id)
	sync_players.rpc()

func start_game() -> void:
	if not multiplayer.is_server():
		push_error("Only the server can start the game")
		return
	
	if players.size() != max_players:
		push_error("Not enough players to start the game")
		return
	
	game_started = true
	server_round = 1
	deal_cards()
	sync_game_state.rpc()

func extract() -> String:
	if cards.is_empty():
		return ""
	
	var index = randi() % cards.size()
	var card = cards[index]
	cards.remove_at(index)
	return card

func deal_cards() -> void:
	for player_id in players:
		while player_cards[player_id].size() < 8:
			var card = extract()
			if card != "":
				player_cards[player_id].append(card)

func next_round() -> void:
	if not multiplayer.is_server():
		push_error("Only the server can advance rounds")
		return
	
	settle_round()
	server_round += 1
	sync_game_state.rpc()

func settle_round() -> void:
	for player_id in players:
		request_card_draw(player_id)

func request_card_draw(player_id: int) -> void:
	if not player_cards.has(player_id):
		push_error("Player not found: " + str(player_id))
		return
	
	var cards_to_draw: int = 4
	
	if server_round == 1 and player_turns.has(player_id) and 0 <= player_turns[player_id] <= 1:
		cards_to_draw = 3
	
	for i in range(cards_to_draw):
		if player_cards[player_id].size() >= 8:
			break
		var card = extract()
		if card != "":
			player_cards[player_id].append(card)

func get_my_cards() -> void:
	request_cards.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func request_cards() -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var data: Array = player_cards.get(sender_id, [])
	send_cards.rpc_id(sender_id, data)

@rpc("authority", "call_remote", "reliable")
func send_cards(data: Array) -> void:
	my_card = data

func sync_game_state() -> void:
	if not multiplayer.is_server():
		return
	
	var data: Dictionary = {}
	data["cards"] = cards
	data["player_cards"] = player_cards
	data["player_turns"] = player_turns
	data["player_hp"] = player_hp
	data["server_round"] = server_round
	data["game_started"] = game_started

	sync_game_state_rpc.rpc(data)

@rpc("authority", "call_remote", "reliable")
func sync_game_state_rpc(data: Dictionary) -> void:
	cards = data["cards"]
	player_cards = data["player_cards"]
	player_turns = data["player_turns"]
	player_hp = data["player_hp"]
	server_round = data["server_round"]
	game_started = data["game_started"]

func sync_players() -> void:
	if not multiplayer.is_server():
		return
	
	var data: Dictionary = {}
	data["players"] = players
	data["player_username"] = player_username
	data["player_hp"] = player_hp

	sync_players_rpc.rpc(data)

@rpc("authority", "call_remote", "reliable")
func sync_players_rpc(data: Dictionary) -> void:
	players = data["players"]
	player_username = data["player_username"]
	player_hp = data["player_hp"]
