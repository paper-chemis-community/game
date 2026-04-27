extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var max_player_num: int
var player_num: int

func create_server(playern: int) -> void:
	max_player_num = playern
	player_num = 1
	if peer.create_server(GameManager.port, playern) != OK:
		return
	setup_multiplayer()
	

func create_client(ip: String) -> void:
	if peer.create_client(ip, GameManager.port) != OK:
		return
	setup_multiplayer()


func setup_multiplayer() -> void:
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(id: int) -> void:
	add_player(id)


func _on_peer_disconnected(id: int):
	remove_player(id)


func add_player(id: int) -> void:
	pass


func remove_player(id: int) -> void:
	pass
