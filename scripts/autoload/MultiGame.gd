extends Node

var PORT: int = 8989
const MAX_HAND_SIZE: int = 8
const INITIAL_HP: int = 4
const DEFAULT_DRAW_COUNT: int = 4
const FIRST_ROUND_DRAW_COUNT: int = 3

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
var game_started: bool = false

func add_player(id: int) -> void:
	if players.size() >= max_players or players.has(id):
		return
	players.append(id)
	player_cards[id] = []
	player_turns[id] = 0
	player_hp[id] = INITIAL_HP

func remove_player(id: int) -> void:
	if not players.has(id):
		return
	players.erase(id)
	for dict in [player_cards, player_turns, player_hp, player_username]:
		dict.erase(id)

func create_server(playern: int) -> void:
	max_players = playern
	if peer.create_server(PORT, playern) != OK:
		return
	_setup_multiplayer()
	add_player(1)

func create_client(ip: String) -> void:
	if peer.create_client(ip, PORT) != OK:
		return
	_setup_multiplayer()

func _setup_multiplayer() -> void:
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	add_player(id)
	sync_players.rpc()

func _on_peer_disconnected(id: int) -> void:
	remove_player(id)
	sync_players.rpc()

func start_game() -> void:
	if not multiplayer.is_server() or players.size() != max_players:
		return
	game_started = true
	server_round = 1
	deal_cards()
	sync_game_state.rpc()

func extract() -> String:
	if cards.is_empty():
		return ""
	var index := randi() % cards.size()
	var card := cards[index]
	cards.remove_at(index)
	return card

func deal_cards() -> void:
	for player_id in players:
		_draw_cards(player_id, MAX_HAND_SIZE)

func next_round() -> void:
	if not multiplayer.is_server():
		return
	settle_round()
	server_round += 1
	sync_game_state.rpc()

func settle_round() -> void:
	for player_id in players:
		var draw_count := DEFAULT_DRAW_COUNT
		if server_round == 1 and player_turns.get(player_id, -1) <= 1:
			draw_count = FIRST_ROUND_DRAW_COUNT
		_draw_cards(player_id, draw_count)

func _draw_cards(player_id: int, count: int) -> void:
	if not player_cards.has(player_id):
		return
	var hand: Array = player_cards[player_id]
	for i in count:
		if hand.size() >= MAX_HAND_SIZE:
			break
		var card := extract()
		if card.is_empty():
			break
		hand.append(card)

func get_my_cards() -> void:
	request_cards.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func request_cards() -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	send_cards.rpc_id(sender_id, player_cards.get(sender_id, []))

@rpc("authority", "call_remote", "reliable")
func send_cards(data: Array) -> void:
	my_card = data

func sync_game_state() -> void:
	if not multiplayer.is_server():
		return
	sync_game_state_rpc.rpc({
		cards = cards,
		player_cards = player_cards,
		player_turns = player_turns,
		player_hp = player_hp,
		server_round = server_round,
		game_started = game_started
	})

@rpc("authority", "call_remote", "reliable")
func sync_game_state_rpc(data: Dictionary) -> void:
	cards = data.cards
	player_cards = data.player_cards
	player_turns = data.player_turns
	player_hp = data.player_hp
	server_round = data.server_round
	game_started = data.game_started

func sync_players() -> void:
	if not multiplayer.is_server():
		return
	sync_players_rpc.rpc({
		players = players,
		player_username = player_username,
		player_hp = player_hp
	})

@rpc("authority", "call_remote", "reliable")
func sync_players_rpc(data: Dictionary) -> void:
	players = data.players
	player_username = data.player_username
	player_hp = data.player_hp
