extends Node2D

var description: String
var type: String

func set_texture(pic: String) -> void:
    $Sprite.texture = ResourceLoader.load(pic)

func set_card(card_name: String) -> void:
    print(card_name)
    set_texture(GameManager.pic_list[card_name])