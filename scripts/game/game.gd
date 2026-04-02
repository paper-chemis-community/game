extends Node2D

var CardScene = preload("res://scenes/game/card.tscn")

var card_list: Array

func _ready() -> void:
	init()
	var card = create_card("Oxygen")
	card.show()
	card.set_pos(300, 300)
	print(card.get_pos())

func init() -> void:
	if multiplayer.is_server():
		$IsServerLabel.text = "GAMEUI_URHOST"
	else:
		$IsServerLabel.text = "GAMEUI_URGUEST"
	
	var addresses: PackedStringArray = IP.get_local_addresses()
	var ipaddress: String = ""
	for address in addresses:
		if address.substr(0, GameManager.ip_begin.length()) == GameManager.ip_begin:
			ipaddress = address
			break
	$IPLabel.text = ipaddress
	$Player1/Username.text = GameManager.username

func create_card(card_name: String):
	var card = CardScene.instantiate()
	add_child(card)
	card.set_card(card_name)
	card_list.append(card)
	return card
