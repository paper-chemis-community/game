extends Node

var isServer: bool

# 基于低级 ENet 多人游戏

func create_server(player_num: int) -> void:
	isServer = true
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8989, player_num)
	multiplayer.multiplayer_peer = peer

func create_client(ip: String) -> void:
	isServer = false
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 8989)
	multiplayer.multiplayer_peer = peer