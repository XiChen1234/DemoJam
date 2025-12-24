class_name FallingKey
extends Node2D

@export var speed: float = 1000

var init_position: Vector2 = Vector2(2100, 200)

func _ready() -> void:
	recycle()

func _process(delta: float) -> void:
	position -= Vector2(speed * delta, 0)
	
	# 如果超出屏幕边缘，则回收
	if position.x < -100:
		recycle()

"""回收/重置音符"""
func recycle() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	position = init_position
