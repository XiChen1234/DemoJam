extends Control

enum LEVEL {
	PERFECT,  # 完美
	GREAT,    # 优秀
	MISS,     # 错过
	NONE,     # 无效
}
# 存储等级文本
const LEVEL_TEXT: Array[String] = [
	"PERFECT", "GREAT", "MISS", "NONE"
]
# 存储时间窗口
const TIMESTAMP_LEVEL: Dictionary[LEVEL, float] = {
	LEVEL.PERFECT: 0.4,
	LEVEL.GREAT: 1.0,
	LEVEL.MISS: 2.0
}
# 存储等级和分数
const LEVEL_SCORE: Dictionary[LEVEL, int] = {
	LEVEL.PERFECT: 250,
	LEVEL.GREAT: 100,
	LEVEL.MISS: 0,
}

@onready var falling_key = preload("res://Scene/falling_key.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

#@export var level_file_path: String = "res://LevelConfig/level_1/level.json" 
#@export var level_file_path: String = "res://LevelConfig/level_2/level.json"
@export var level_file_path: String = "res://LevelConfig/level_3/level.json"

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
	
	if not fk_queue.is_empty():
		if current_time - fk_queue[0].timestamp >= TIMESTAMP_LEVEL[LEVEL.MISS]:
			print(fk_queue[0].position)
			destroy()


"""获取音乐内时间戳"""
func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()


"""
左键单击，可能的情况
1. 左键单击
2. 左键长按的起始
3. 连打
"""
func left_click():
	if fk_queue.is_empty():
		print("当前队列为空")
		return
	
	var timestamp: float = get_music_time()
	var fk_inst: FallingKey = fk_queue[0]
	
	var diff: float = fk_inst.timestamp - timestamp
	if diff > TIMESTAMP_LEVEL[LEVEL.MISS]:
		print("太早了，当前时间戳：%f" % timestamp)
		return
	
	match fk_inst.type:
		FallingKey.TYPE.QUICK_BIT:
			# 连打，不分左右触发，音符不destroy，等连打结束由其自己控制
			beat(LEVEL.GREAT)
		FallingKey.TYPE.LEFT_CLICK:
			if diff > TIMESTAMP_LEVEL[LEVEL.MISS]:
				return
			destroy()
			if diff > TIMESTAMP_LEVEL[LEVEL.GREAT]:
				beat(LEVEL.MISS)
			elif diff > TIMESTAMP_LEVEL[LEVEL.PERFECT]:
				beat(LEVEL.GREAT)
			else:
				beat(LEVEL.PERFECT)
		FallingKey.TYPE.LEFT_LONG_PRESS:
			if diff > TIMESTAMP_LEVEL[LEVEL.MISS]:
				return
			if diff > TIMESTAMP_LEVEL[LEVEL.GREAT]:
				destroy() # 长按音符，初始单击没有击中直接destroy
				beat(LEVEL.MISS)
			elif diff > TIMESTAMP_LEVEL[LEVEL.PERFECT]:
				beat(LEVEL.GREAT)
			else:
				beat(LEVEL.PERFECT)
	
	print("左键单击 - 音乐时间戳: %f 秒" % [timestamp])

"""
右键单击，可能的情况
1. 右键单击
2. 右键长按的起始
3. 连打
"""
func right_click():
	var timestamp: float = get_music_time()
	print("右键单击 - 音乐时间戳: %f 秒" % [timestamp])


"""
左键长按释放，可能的情况：
1. 长按释放
"""
func left_long_press(duration: float):
	var timestamp = get_music_time()
	print("左键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


"""
右键长按释放，可能的情况：
1. 长按释放
"""
func right_long_press(duration: float):
	var timestamp = get_music_time()
	print("右键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


"""
有效击打函数（miss也算有效击打，只是不加分、清combo而已）
参数：传入的等级
效果：
1. 加分
2. 加/删combo
3. 飘字
"""
func beat(level: LEVEL) -> void:
	print(LEVEL_TEXT[level])


"""从队列弹出、并销毁音符"""
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
