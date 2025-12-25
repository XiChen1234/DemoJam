class_name Cat
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var hitting: bool = false
var haing: bool = false


func _process(_delta: float) -> void:
	if hitting:
		animated_sprite_2d.play("hit")
	elif haing:
		animated_sprite_2d.play("ha")
	else:
		animated_sprite_2d.play("idle")


func start_hit():
	hitting = true


func stop(_duration: float = 0):
	hitting = false
	haing = false


func start_ha():
	haing = true
