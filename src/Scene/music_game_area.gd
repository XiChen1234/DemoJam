extends Node2D

enum LEVEL {
	PERFECT,  # 完美
	GREAT,    # 优秀
	MISS,     # 错过
	NONE,     # 无效
}

const LEVEL_TEXT: Array[String] = [
	"PERFECT", "GREAT", "MISS", "NONE"
]

# 存储时间窗口
const TIMESTAMP_LEVEL: Dictionary[LEVEL, float] = {
	LEVEL.PERFECT: 0.5,
	LEVEL.GREAT: 1.0,
	LEVEL.MISS: 1.5
}

# 存储等级和分数
const LEVEL_SCORE: Dictionary[LEVEL, int] = {
	LEVEL.PERFECT: 250,
	LEVEL.GREAT: 100,
	LEVEL.MISS: 0,
}

@onready var falling_key = preload("res://Scene/falling_key.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var level_file_path: String = "res://LevelConfig/level_1/level.json"

var init_position: Vector2 = Vector2(1000, 0)
var offset: float = 4


## 关卡相关
var timeline_data: Array = [] 
var timelime_count: int = 0
var falling_key_index: int = 0
var fk_queue: Array[FallingKey] = []

func _ready() -> void:
	load_level_data()
	
	audio_stream_player.play()


func _process(_delta: float) -> void:
	var current_time: float = get_music_time()
	gene_falling_key(current_time)


"""获取音乐内时间戳"""
func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()


func left_click():
	var timestamp = get_music_time()
	print("左键单击 - 音乐时间戳: %f 秒" % [timestamp])
	#var level: LEVEL = judge_click_fall_key(
		#timestamp, 
		#FallingKey.TYPE.LEFT_CLICK)
	#print(LEVEL_TEXT[level])

func right_click():
	var timestamp = get_music_time()
	print("右键单击 - 音乐时间戳: %f 秒" % [timestamp])

func left_long_press(duration: float):
	var timestamp = get_music_time()
	print("左键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])

func right_long_press(duration: float):
	var timestamp = get_music_time()
	print("右键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


#"""
#时间戳对比检测
#队列首部的音符，若超出某范围，直接销毁回收（由音符控制）
#在此之前，都是判定区域，对队列首部的音符元素进行判定
#在判定线之前，若miss，不操作；
#在判定线之后，若miss，则miss；
#其他根据时间差绝对值来进行判定
#"""
#func judge_click_fall_key(click_time: float, type: FallingKey.TYPE) -> LEVEL:
	#if fk_queue.is_empty():
		#return LEVEL.NONE
	#
	#var fk_inst: FallingKey = fk_queue[0]
	## 类型匹配检查函数
	#var diff: float = abs(click_time - fk_inst.timestamp)
	#
	#if diff > TIMESTAMP_LEVEL[LEVEL.MISS]:
		#return LEVEL.NONE
	#
	#if not type == fk_inst.type:
		#destroy()
		#return LEVEL.MISS
	#
	#if diff <= TIMESTAMP_LEVEL[LEVEL.PERFECT]:
		#destroy()
		#return LEVEL.PERFECT
	#elif diff <= TIMESTAMP_LEVEL[LEVEL.GREAT]:
		#destroy()
		#return LEVEL.GREAT
		#
	#destroy()
	#return LEVEL.MISS



#"""长按的判定 todo"""
#func judge_long_fall_key() -> void:
	#pass


"""销毁音符"""
func destroy():
	var fk_inst: FallingKey = fk_queue.pop_front()
	PoolManager.current.recycle(fk_inst)


## 关卡部分
"""根据关卡信息生成音符"""
func gene_falling_key(current_time: float) -> void:
	# 音符生成完了
	if falling_key_index >= timelime_count:
		return
	
	var timestamp: float = timeline_data[falling_key_index].get("timestamp")
	if timestamp - offset < current_time:
		print("当前时间: %s，生成音符" % current_time)
		#print(timeline_data[falling_key_index].get("name"))
		var type = timeline_data[falling_key_index].get("type")
		var duration = timeline_data[falling_key_index].get("duration")
		
		var fk_inst: FallingKey = PoolManager.current.spawn_object(falling_key, init_position)
		fk_inst.edit(type, timestamp, duration)
		PoolManager.current.active(fk_inst)
		
		fk_queue.append(fk_inst) # 加入队列
		falling_key_index += 1


"""加载关卡数据"""
func load_level_data() -> void:
	var file: FileAccess = FileAccess.open(level_file_path, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		var json_data: Variant = JSON.parse_string(json_string)
		timeline_data = json_data.get("timeline")
		timelime_count = timeline_data.size()
