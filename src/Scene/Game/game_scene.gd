extends Control

@onready var cat: Cat = $Cat
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var note_track: Panel = $NoteTrack
@onready var input_controller: InputController = $InputController
@onready var judge: Judge = $Judge
@onready var label_layer: LabelLayer = $LabelLayer

@export var long_press_threshold: float = 0.5
var left_pressed_time: float = 0
var right_pressed_time: float = 0

# 关卡相关数据
@export var level_file_path: String = "res://LevelConfig/level_1/level.json" 
var timeline_data: Array  = []
var note_count: int = 0
var note_queue: Array[BaseNote] = []


func _ready() -> void:
	connect_signal()
	load_level_data()
	audio_stream_player.play()


func _process(_delta: float) -> void:
	var _timestamp = get_music_time()
	#print(_timestamp)


func connect_signal() -> void:
	"""用户输入信号"""
	input_controller.left_click.connect(_on_left_pressed)
	input_controller.right_click.connect(_on_right_pressed)
	input_controller.left_release.connect(_on_left_released)
	input_controller.right_release.connect(_on_right_released)
	input_controller.left_hold_release.connect(_on_left_hold_released)
	input_controller.right_hold_release.connect(_on_right_hold_released)
	# 将judge信号连接移到这里，只连接一次
	judge.note_miss.connect(_on_miss)
	judge.note_great.connect(_on_great)
	judge.note_perfect.connect(_on_perfect)
	judge.rapid_hit.connect(_on_rapid)
	judge.note_hold.connect(_on_hold)


"""连接音符信号（创建后连接）"""
func connect_note_signal(note: BaseNote) -> void:
	note.note_destroy.connect(_on_miss) # 音符自毁miss
	if note.type == BaseNote.Type.RAPID:
		note.rapid_destory.connect(_on_rapid_destory) # rapid自毁

"""点击事件触发函数"""
func _on_left_pressed():
	print("左键点击")
	cat.start_hit()
	var current_time: float = get_music_time()
	# 判定系统
	"""
	判定系统需要的
	1. 当前时间
	2. 首位音符，由他获取音符类型、时间戳、持续时间等
	"""
	if note_queue.is_empty():
		return
	var note: BaseNote = note_queue[0]
	var type: BaseNote.Type = note.type
	# 检查type，无效直接返回
	if type == BaseNote.Type.RIGHT_CLICK or type == BaseNote.Type.RIGHT_HOLD:
		return
	# 检查时间diff
	judge.judge_click(current_time, type, note)

func _on_right_pressed():
	print("右键点击")
	cat.start_ha()
	var current_time: float = get_music_time()
	# 判定系统
	"""
	判定系统需要的
	1. 当前时间
	2. 首位音符，由他获取音符类型、时间戳、持续时间等
	"""
	if note_queue.is_empty():
		return
	var note: BaseNote = note_queue[0]
	var type: BaseNote.Type = note.type
	# 检查type，无效直接返回
	if type == BaseNote.Type.LEFT_CLICK or type == BaseNote.Type.LEFT_HOLD:
		return
	# 检查时间diff
	judge.judge_click(current_time, type, note)

func _on_left_released():
	#print("左键松开")
	cat.stop()

func _on_right_released():
	#print("右键松开")
	cat.stop()

func _on_left_hold_released(duration: float):
	print("左键长按结束：持续时间： %f" % duration)
	cat.stop()
	var current_time: float = get_music_time()
	if note_queue.is_empty():
		return
	var note: BaseNote = note_queue[0]
	var type: BaseNote.Type = note.type
	if type == BaseNote.Type.LEFT_HOLD:
		judge.judge_hold(current_time, note)

func _on_right_hold_released(duration: float):
	print("右键长按结束：持续时间： %f" % duration)
	cat.stop()
	var current_time: float = get_music_time()
	if note_queue.is_empty():
		return
	var note: BaseNote = note_queue[0]
	var type: BaseNote.Type = note.type
	if type == BaseNote.Type.RIGHT_HOLD:
		judge.judge_hold(current_time, note)


"""
触发miss的情况
- 除rapid外，音符自动销毁
- 点击超过时间窗口
"""
func _on_miss() -> void:
	print("miss")  
	label_layer.spawn_result(LabelLayer.ResultType.MISS)
	note_queue[0].queue_free()
	note_queue.pop_front()

"""
触发great的情况
- 点击在great时间窗口
- 音符类型：Click、Hold
"""
func _on_great() -> void:
	print("great")
	label_layer.spawn_result(LabelLayer.ResultType.GREAT)
	if note_queue[0].type == BaseNote.Type.LEFT_CLICK or \
		note_queue[0].type == BaseNote.Type.RIGHT_CLICK:
		note_queue[0].queue_free()
		note_queue.pop_front()
	else:
		return

"""
触发perfect的情况
- 点击在perfect时间窗口
- 音符类型：Click、Hold
"""
func _on_perfect() -> void:
	print("perfect")
	label_layer.spawn_result(LabelLayer.ResultType.PERFECT)
	if note_queue[0].type == BaseNote.Type.LEFT_CLICK or \
		note_queue[0].type == BaseNote.Type.RIGHT_CLICK:
		note_queue[0].queue_free()
		note_queue.pop_front() 
	else:
		return

"""
触发rapid的情况
- 点击在rapid的时间窗口
"""
var combo: int = 0
func _on_rapid() -> void:
	print("rapid")
	label_layer.spawn_result(LabelLayer.ResultType.RAPID)
	combo += 1

"""
触发hold的情况
- 释放在hold的时间窗口
"""
func _on_hold() -> void:
	print("hold")
	label_layer.spawn_result(LabelLayer.ResultType.HOLD)
	note_queue[0].queue_free()
	note_queue.pop_front() 

"""
触发rapid destory的情况
- rapid自毁，无惩罚
"""
func _on_rapid_destory() -> void:
	print("rapid destory")
	note_queue[0].queue_free()
	note_queue.pop_front()


"""加载关卡数据，并生成音符"""
func load_level_data() -> void:
	var file: FileAccess = FileAccess.open(level_file_path, FileAccess.READ)
	if file:
		var path: String = file.get_as_text()
		var json_data: Dictionary = JSON.parse_string(path)
		timeline_data = json_data.get("timeline")
		note_count = timeline_data.size()
		#print(timeline_data[0])
		for i in range(note_count):
			var note: BaseNote = NoteFactory.create_note(timeline_data[i])
			connect_note_signal(note)
			note_track.add_child(note)
			note_queue.append(note)


"""获取音乐时间"""
func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + \
		AudioServer.get_time_since_last_mix()
