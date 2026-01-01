extends Control
class_name BeatButton

@onready var texture_rect: TextureRect = $TextureRect

@export var normal_texture: Texture2D
@export var pressed_texture: Texture2D

var _is_pressed: bool = false


func _ready() -> void:
	_update_state()


func press() -> void:
	_is_pressed = true
	_update_state()


func release() -> void:
	_is_pressed = false
	_update_state()


func _update_state() -> void:
	if _is_pressed:
		texture_rect.texture = pressed_texture
	else:
		texture_rect.texture = normal_texture
