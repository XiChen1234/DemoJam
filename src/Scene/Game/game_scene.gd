extends Control

signal score_changed(score: int)
signal combo_changed(current_combo: int, max_combo: int)

# 界面组件
@onready var cat: Cat = $Cat
@onready var note_track: Panel = $NoteTrack
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var texture_progress_bar: TextureProgressBar = $UI/Control/TextureProgressBar
@onready var gabber: TextureRect = $UI/Control/TextureProgressBar/Gabber
# 逻辑计算
@onready var input_controller: InputController = $InputController
@onready var judge: Judge = $Judge
@onready var label_layer: LabelLayer = $LabelLayer
# UI显示
@onready var countdown_label: Label = $UI/Control/CountdownLabel
@onready var pause_layer: PauseLayer = $UI/Control/PauseLayer
@onready var score_label: Label = $UI/Control/ScoreLabel
@onready var combo_label: Label = $UI/Control/ComboLabel

# 关卡相关数据
var level_data: LevelData
var timeline_data: Array  = []
var note_count: int = 0
var note_queue: Array[BaseNote] = []

# 进度条数据
enum GameState {
	COUNTDOWN,
	PLAYING,
	FINISHED
}
var game_state: GameState = GameState.COUNTDOWN
# 积分数据
var score: int = 0
var current_combo: int = 0
var max_combo: int = 0
# 分值配置表
const SCORE_TABLE: Array[int] = [
	1000,	# perfect
	500,	# great
	800,	# hold
	50		# rapid
]

# 测试数据
var test_json_path: String
var test_music_path: String


func _ready() -> void:
	# 1. 加载关卡 & 音符
	if GameManager.test_mode:
		print("进入测试模式")
		load_level_data(GameManager.json_path)
		audio_stream_player.stream = AudioStreamOggVorbis.load_from_file(GameManager.music_path)
		GameManager.test_mode = false
	else:
		level_data = GameManager.selected_level
		load_level_data(level_data.json_path)
		load_music(level_data.music_path)
	
	# 2. 关卡初始化：连接信号，设置进度条
	connect_signal()
	texture_progress_bar.min_value = 0
	texture_progress_bar.max_value = audio_stream_player.stream.get_length()

	# 3. 最后才开始倒计时
	start_countdown()


"""测试用跳过音游的按钮"""
func _on_test_skip():
	get_tree().change_scene_to_file("res://Scene/UI/result_scene.tscn")


func _process(_delta: float) -> void:
	if game_state == GameState.PLAYING:
		var timestamp: float = get_music_time()
		for note: BaseNote in note_queue:
			note.update_by_time(timestamp)
	
	var value: float
	var ratio: float
	var max_value: float = texture_progress_bar.max_value
	match game_state:
		GameState.COUNTDOWN:
			value = 0
			ratio = 0
		GameState.PLAYING:
			value = get_music_time()
			ratio = value / max_value
		GameState.FINISHED:
			value = max_value
			ratio = 1
	texture_progress_bar.value = value
	gabber.position.x = texture_progress_bar.size.x * ratio - 75


"""倒计时播放"""
func start_countdown() -> void:
	await show_number("3")
	await show_number("2")
	await show_number("1")
	game_state = GameState.PLAYING # 游戏状态切换为1
	audio_stream_player.play()


func show_number(text: String) -> void:
	countdown_label.text = text
	countdown_label.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_property(countdown_label, "modulate:a", 0.0, 1.0)

	await tween.finished


func connect_signal() -> void:
	"""用户输入信号"""
	input_controller.left_click.connect(_on_left_pressed)
	input_controller.right_click.connect(_on_right_pressed)
	input_controller.left_release.connect(_on_left_released)
	input_controller.right_release.connect(_on_right_released)
	input_controller.left_hold_release.connect(_on_left_hold_released)
	input_controller.right_hold_release.connect(_on_right_hold_released)
	"""用于判定的judge信号"""
	judge.note_miss.connect(_on_miss)
	judge.note_great.connect(_on_great)
	judge.note_perfect.connect(_on_perfect)
	judge.rapid_hit.connect(_on_rapid)
	judge.note_hold.connect(_on_hold)
	"""连接score和combo的信号"""
	score_changed.connect(_on_score_changed)
	combo_changed.connect(_on_combo_changed)


"""连接音符信号（创建后连接）"""
func connect_note_signal(note: BaseNote) -> void:
	note.note_destroy.connect(_on_miss) # 音符自毁miss
	if note.type == BaseNote.Type.RAPID:
		note.rapid_destory.connect(_on_rapid_destory) # rapid自毁


"""Score和Combo的UI更新代码"""
func _on_score_changed(value: int) -> void:
	score_label.text = "Score: %07d" % value


func _on_combo_changed(current: int) -> void:
	if current > 0:
		combo_label.visible = true
		combo_label.text = "%d x Combo" % current
	else:
		combo_label.visible = false


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
	
	reset_combo()
	
	note_queue[0].queue_free()
	note_queue.pop_front()


"""
触发perfect的情况
- 点击在perfect时间窗口
- 音符类型：Click、Hold
"""
func _on_perfect() -> void:
	print("perfect")
	label_layer.spawn_result(LabelLayer.ResultType.PERFECT)
	
	add_score(SCORE_TABLE[0])
	add_combo()
	
	if note_queue[0].type == BaseNote.Type.LEFT_CLICK or \
		note_queue[0].type == BaseNote.Type.RIGHT_CLICK:
		note_queue[0].queue_free()
		note_queue.pop_front() 
	else:
		return


"""
触发great的情况
- 点击在great时间窗口
- 音符类型：Click、Hold
"""
func _on_great() -> void:
	print("great")
	label_layer.spawn_result(LabelLayer.ResultType.GREAT)
	
	add_score(SCORE_TABLE[1])
	add_combo()
	
	if note_queue[0].type == BaseNote.Type.LEFT_CLICK or \
		note_queue[0].type == BaseNote.Type.RIGHT_CLICK:
		note_queue[0].queue_free()
		note_queue.pop_front()
	else:
		return


"""
触发hold的情况
- 释放在hold的时间窗口
"""
func _on_hold() -> void:
	print("hold")
	label_layer.spawn_result(LabelLayer.ResultType.HOLD)
	
	add_score(SCORE_TABLE[2])
	add_combo()
	
	note_queue[0].queue_free()
	note_queue.pop_front() 


"""
触发rapid的情况
- 点击在rapid的时间窗口
"""
func _on_rapid() -> void:
	print("rapid")
	label_layer.spawn_result(LabelLayer.ResultType.RAPID)
	
	add_score(SCORE_TABLE[3])
	add_combo()


"""算分计数工具方法"""
func add_combo() -> void:
	current_combo += 1
	if current_combo > max_combo:
		max_combo = current_combo
	
	combo_changed.emit(current_combo)


func reset_combo() -> void:
	current_combo = 0
	combo_changed.emit(current_combo)

func add_score(value: int) -> void:
	score += value
	score_changed.emit(score)


"""
触发rapid destory的情况
- rapid自毁，无惩罚
"""
func _on_rapid_destory() -> void:
	print("rapid destory")
	note_queue[0].queue_free()
	note_queue.pop_front()


"""加载关卡数据，并生成音符"""
func load_level_data(json_path: String) -> void:
	var file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
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


"""加载音乐"""
func load_music(music_path: String) -> void:
	audio_stream_player.stream = load(music_path)


"""获取音乐时间"""
func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + \
		AudioServer.get_time_since_last_mix()


"""最终音乐结束的信号"""
func _on_finish() -> void:
	print("音乐播放结束，进入结算阶段")
	game_state = GameState.FINISHED # 音乐播放结束，倒计时前
	await get_tree().create_timer(3).timeout
	print("最终分数:", score)
	print("最大连段:", max_combo)
	GameManager.last_result = {
		"score": score,
		"max_combo": max_combo
	}
	get_tree().change_scene_to_file("res://Scene/UI/result_scene.tscn")


"""暂停按钮，同ESC"""
func _on_pause() -> void:
	pause_layer.pause()
