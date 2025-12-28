class_name BaseNote
extends Node2D

@warning_ignore("unused_signal")
signal note_destroy


"""
基础音符父类脚本，包含音符的所有基本操作
"""
enum Type {
	LEFT_CLICK, RIGHT_CLICK,	# 单击 0 1
	LEFT_HOLD, RIGHT_HOLD,		# 长按 2 3
	RAPID,						# 连打 4
	BASE,						# 无用占位 5
}
const TypeIndex: Array[Type] = [
	Type.LEFT_CLICK, Type.RIGHT_CLICK, Type.LEFT_HOLD, Type.RIGHT_HOLD, 
	Type.RAPID, Type.BASE,
]

@export var type: Type
@export var timestamp: float
@export var speed: float

var init_position: Vector2 = Vector2(250, 150) # deadline基准线
var deadline: float = 130 # 自毁线


func _process(delta: float) -> void:
	position.x -= speed * delta


func init_config(data: Dictionary) -> void:
	type = TypeIndex[data.get("type")]
	timestamp = data.get("timestamp")
	speed = data.get("speed")
	position = init_position + Vector2(timestamp * speed, 0) + Vector2(100, 0)
