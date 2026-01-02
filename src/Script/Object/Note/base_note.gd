class_name BaseNote
extends Node2D

@warning_ignore("unused_signal")
signal timeout(note: BaseNote)
@warning_ignore("unused_signal")
signal expired(note: BaseNote)

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
	Type.RAPID
]

@export var type: Type
@export var timestamp: float
@export var speed: float

var current_time: float = 0
var init_position: Vector2 = Vector2(250, 150) # deadline基准线
const DEAD_TIMESTAMP: float = 0.15
var deadline: float = 130 # 自毁线


func init_config(data: Dictionary) -> void:
	type = TypeIndex[data.get("type")]
	timestamp = data.get("timestamp")
	speed = data.get("speed")
	position = Vector2(init_position.x + timestamp * speed, 150)


func update_by_time(time: float):	
	current_time = time
	var diff_time = timestamp - current_time
	position.x = init_position.x + diff_time * speed
