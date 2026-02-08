extends Node2D

var description: String
var type: String
var card_name: String

func set_texture(pic: String) -> void:
    $Sprite.texture = ResourceLoader.load(pic)

func set_card(cname: String) -> void:
    card_name = cname
    set_texture(GameManager.pic_list[card_name])