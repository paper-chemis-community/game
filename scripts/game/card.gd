extends Node2D

func set_texture(pic: String) -> void:
    $Sprite.texture = ResourceLoader.load(pic)

