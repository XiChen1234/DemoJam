extends Node2D
class_name NPC

@onready var sprite_2d: Sprite2D = $Sprite2D

func set_npc_texture(texture: Texture):
	sprite_2d.texture = texture
