extends Node2D

enum LEVEL {
	PERFECT,  # 完美
	GREAT,    # 优秀
	MISS      # 错过
}

const TIMESTAMP_LEVEL := {
	1.0: LEVEL.PERFECT,
	2.0: LEVEL.GREAT,
	5.0: LEVEL.MISS,
}

const LEVEL_SCORE := {
	LEVEL.PERFECT: 250,
	LEVEL.GREAT: 100,
	LEVEL.MISS: 0,
}

@onready var falling_key = preload("res://Scene/falling_key.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var pool_size: int = 10
@export var level_file_path: String = "res://LevelConfig/level_1/level_1.json"

var fk_pool: Array[FallingKey] = []
var init_position: Vector2 = Vector2(2100, 200)

## 关卡相关
var level_data: Array = []
var level_count: int = 0
var falling_key_index: int = 0
var fk_queue: Array = []

func _ready() -> void:
	load_level_data()
	
	audio_stream_player.play()
	
	initialize_pool()


func _process(_delta: float) -> void:
	gene_falling_key()


"""获取音乐内时间戳"""
func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()


func left_click():
	var timestamp = get_music_time()
	print("左键单击 - 音乐时间戳: %f 秒" % [timestamp])
	var level: LEVEL = judge_click_fall_key(timestamp)
	


func right_click():
	var timestamp = get_music_time()
	print("右键单击 - 音乐时间戳: %f 秒" % [timestamp])


func left_long_press(duration: float):
	var timestamp = get_music_time()
	print("左键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


func right_long_press(duration: float):
	var timestamp = get_music_time()
	print("右键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


## 关卡部分
"""
时间戳对比检测
队列首部的音符，若超出某范围，直接销毁回收（由音符控制）
在此之前，都是判定区域，对队列首部的音符元素进行判定
在判定线之前，若miss，不操作；
在判定线之后，若miss，则miss；
其他根据时间差绝对值来进行判定
"""
func judge_click_fall_key(click_time: float) -> LEVEL:
	print("judge")
	return LEVEL.PERFECT

func judge_long_fall_key() -> void:
	pass

"""生成音符"""
func gene_falling_key() -> void:
	if falling_key_index >= level_count:
		return
	var current_time: float = get_music_time()
	var timestamp: float = level_data[falling_key_index].get("timestamp")
	if timestamp < current_time:
		#print(level_data[falling_key_index].get("name"))
		var type = level_data[falling_key_index].get("type")
		var duration = level_data[falling_key_index].get("duration")
		var fk_inst: FallingKey = get_from_pool(type, timestamp, duration)
		
		activate_falling_key(fk_inst)
		
		fk_queue.append(fk_inst) # 将音符添加到队列中
		falling_key_index += 1


"""加载关卡数据"""
func load_level_data() -> void:
	var file: FileAccess = FileAccess.open(level_file_path, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		var json_data: Variant = JSON.parse_string(json_string)
		level_data = json_data.get("timeline")
		level_count = level_data.size()


## 对象池部分
"""激活对象"""
func activate_falling_key(fk_inst: FallingKey) -> void:
	# 重置音符状态
	fk_inst.visible = true
	fk_inst.set_process(true)
	fk_inst.set_physics_process(true)


"""从对象池中获取对象"""
func get_from_pool(
	p_type: FallingKey.TYPE, 
	p_timestamp: float, 
	p_duration: float = 0) -> FallingKey:
	
	for fk_inst in fk_pool:
		if not fk_inst.visible:
			fk_inst.type = p_type
			fk_inst.timestamp = p_timestamp
			fk_inst.duration = p_duration 
			fk_inst.set_texture()
			return fk_inst
	
	return expand_pool()


"""扩展对象池"""
func expand_pool() -> FallingKey:
	var fk_inst: FallingKey = create_falling_key()
	# 添加到场景和对象池
	add_child(fk_inst)
	fk_pool.append(fk_inst)
	return fk_inst


"""初始化对象池"""
func initialize_pool() -> void:
	for i in range(pool_size):
		var fk_inst: FallingKey = create_falling_key()
		# 添加到场景和对象池
		add_child(fk_inst)
		fk_pool.append(fk_inst)

"""创建音符"""
func create_falling_key() -> FallingKey:
	var fk_inst: FallingKey = falling_key.instantiate()
	fk_inst.set_process(false)
	fk_inst.set_physics_process(false)
	return fk_inst
