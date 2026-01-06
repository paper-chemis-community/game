extends Node2D

func _ready() -> void:
	init()

func init() -> void:
	if MultiGame.isServer:
		$IsServerLabel.text = "房间运行中：您是房主"
	else:
		$IsServerLabel.text = "房间运行中：您是房客"
	
	var addresses: PackedStringArray = IP.get_local_addresses()
	var ipaddress: String = ""
	for address in addresses:
		if address.substr(0, 8) == "192.168.":
			ipaddress = address
	$IPLabel.text = ipaddress
