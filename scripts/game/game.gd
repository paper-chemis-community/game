extends Node2D

var CardScene = preload("res://prefabs/game/card.tscn")

var card_list: Array

func _ready() -> void:
	init()
	var card = create_card("Oxygen")
	card.show()

func init() -> void:
	if multiplayer.is_server():
		$IsServerLabel.text = "房间运行中：您是房主"
	else:
		$IsServerLabel.text = "房间运行中：您是房客"
	
	var addresses: PackedStringArray = IP.get_local_addresses()
	var ipaddress: String = ""
	for address in addresses:
		if address.substr(0, GameManager.ip_begin.length()) == GameManager.ip_begin:
			ipaddress = address
	$IPLabel.text = ipaddress
	$Player1/Username.text = GameManager.username

func create_card(card_name: String):
	var card = CardScene.instantiate()
	add_child(card)
	card.set_card(card_name)
	card_list.append(card)
	return card
