class_name FallingKey
extends Node2D

enum TYPE {
	LEFT_CLICK, RIGHT_CLICK, LEFT_LONG_PRESS, RIGHT_LONG_PRESS,ELSE
}

const TYPE_TEXTURES = {
	TYPE.LEFT_CLICK: preload("res://Assert/Art/red-arrows.png"),
	TYPE.RIGHT_CLICK: preload("res://Assert/Art/blue-arrows.png"),
	TYPE.LEFT_LONG_PRESS: preload("res://Assert/Art/red-line.png"),
	TYPE.RIGHT_LONG_PRESS: preload("res://Assert/Art/blue-line.png"),
	TYPE.ELSE: preload("res://Assert/Art/arrow.png"),
}

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed: float = 1000
@export var type: TYPE
@export var timestamp: float
@export var duration: float # 单击为默认0，长按不为零

var init_position: Vector2 = Vector2(2100, 200)

func _ready() -> void:
	recycle()

func _process(delta: float) -> void:
	position -= Vector2(speed * delta, 0)
	
	# 如果超出屏幕边缘，则回收
	if position.x < -100:
		recycle()


"""设置纹理"""
func set_texture() -> void:
	var texture: Resource = TYPE_TEXTURES[type]
	match type:
		TYPE.LEFT_CLICK, TYPE.RIGHT_CLICK:
			sprite_2d.texture = texture
		TYPE.LEFT_LONG_PRESS, TYPE.RIGHT_LONG_PRESS:
			# 暂时用这个箭头占位
			sprite_2d.texture = TYPE_TEXTURES[TYPE.ELSE]


"""回收/重置音符"""
func recycle() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	position = init_position
