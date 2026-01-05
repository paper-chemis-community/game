extends Node

func create_server(player_num: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8989, player_num)
	multiplayer.multiplayer_peer = peer

func create_client(ip: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 8989)
	multiplayer.multiplayer_peer = peer