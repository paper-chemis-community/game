extends Node2D

var description: String
var type: String
var card_name: String

func set_texture(pic: String) -> void:
	var image = Image.new()
	image.load(pic)
	$Sprite.texture = ImageTexture.create_from_image(image)

func set_card(cname: String) -> void:
	card_name = cname
	set_texture("user://download/sources/%s/assets/pics/%s" % [DownloadManager.uuid, GameManager.pic_list[card_name]])
