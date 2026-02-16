extends Node

var peer = ENetMultiplayerPeer.new()
var players: Array
var player_num

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

func create_client(ip: String) -> void:
	peer.create_client(ip, 8989)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int):
	pass