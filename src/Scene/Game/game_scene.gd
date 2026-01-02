extends Control

# 界面组件
@onready var cat: Cat = $InputFeedback/Cat
@onready var input_feedback: InputFeedback = $InputFeedback
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
var game_result: GameResult

# 进度条数据
enum GameState {
	COUNTDOWN,
	PLAYING,
	FINISHED
}
var game_state: GameState = GameState.COUNTDOWN

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
	
	# 2. 关卡初始化：设置进度条，初始化关卡得分相关值，连接信号
	texture_progress_bar.min_value = 0
	texture_progress_bar.max_value = audio_stream_player.stream.get_length()
	game_result = GameResult.new()
	connect_signal()

	# 3. 最后才开始倒计时
	start_countdown()


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
	"""显示UI的信号"""
	game_result.score_changed.connect(_on_score_changed)
	game_result.combo_changed.connect(_on_combo_changed)


"""Score和Combo的UI更新代码"""
func _on_score_changed(score: int) -> void:
	score_label.text = "Score: %07d" % score


func _on_combo_changed(current: int) -> void:
	if current > 0:
		combo_label.visible = true
		combo_label.text = "%d x Combo" % current
	else:
		combo_label.visible = false


"""点击事件触发函数"""
func _on_left_pressed():
	print("左键点击")
	input_feedback.on_left_pressed()
	
	if game_state != GameState.PLAYING:
		return
	if note_queue.is_empty():
		return
	
	var time := get_music_time()
	var note: BaseNote = note_queue[0]
	var result: Judge.JudgeResult
	if note.type == BaseNote.Type.RAPID:
		result = judge.judge_rapid(time, note)
	else:
		result = judge.judge_press(time, note, Judge.SideInput.LEFT)
	
	_handle_judge_result(result)


func _on_right_pressed():
	print("右键点击")
	input_feedback.on_right_pressed()
	
	if game_state != GameState.PLAYING:
		return
	if note_queue.is_empty():
		return
	
	var time: float = get_music_time()
	var note: BaseNote = note_queue[0]
	var result: Judge.JudgeResult
	if note.type == BaseNote.Type.RAPID:
		result = judge.judge_rapid(time, note)
	else:
		result = judge.judge_press(time, note, Judge.SideInput.RIGHT)
	
	_handle_judge_result(result)


func _on_left_released():
	#print("左键松开")
	input_feedback.on_left_released()


func _on_right_released():
	#print("右键松开")
	input_feedback.on_right_released()


func _on_left_hold_released():
	input_feedback.on_left_released()

	if game_state != GameState.PLAYING:
		return
	if note_queue.is_empty():
		return
	
	var note: BaseNote = note_queue[0]
	if note.type == BaseNote.Type.LEFT_CLICK or \
		note.type == BaseNote.Type.RIGHT_CLICK:
		return

	var result = judge.judge_hold_release(
		get_music_time(),
		note,
		Judge.SideInput.LEFT
	)

	_handle_judge_result(result)


func _on_right_hold_released():
	input_feedback.on_right_released()

	if game_state != GameState.PLAYING:
		return
	if note_queue.is_empty():
		return
	
	var note: BaseNote = note_queue[0]
	if note.type == BaseNote.Type.LEFT_CLICK or \
		note.type == BaseNote.Type.RIGHT_CLICK:
		return

	var result = judge.judge_hold_release(
		get_music_time(),
		note,
		Judge.SideInput.RIGHT
	)

	_handle_judge_result(result)


"""统一处理结果"""
func _handle_judge_result(result: Judge.JudgeResult) -> void:
	if result == Judge.JudgeResult.NONE:
		return
	
	# 进入得分系统
	game_result.apply_judge_result(result)
	
	match result:
		Judge.JudgeResult.NONE:
			return
		Judge.JudgeResult.MISS:
			_on_miss()
		Judge.JudgeResult.GREAT:
			_on_great()
		Judge.JudgeResult.PERFECT:
			_on_perfect()
		Judge.JudgeResult.HOLD_OK:
			_on_hold()
		Judge.JudgeResult.RAPID_HIT:
			_on_rapid()



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
触发hold的情况
- 释放在hold的时间窗口
"""
func _on_hold() -> void:
	print("hold")
	label_layer.spawn_result(LabelLayer.ResultType.HOLD)
	
	note_queue[0].queue_free()
	note_queue.pop_front() 


"""
触发rapid的情况
- 点击在rapid的时间窗口
"""
func _on_rapid() -> void:
	print("rapid")
	label_layer.spawn_result(LabelLayer.ResultType.RAPID)


"""
触发rapid destory的情况
- rapid自毁，无惩罚
"""
func _on_rapid_destory() -> void:
	print("rapid destory")
	note_queue[0].queue_free()
	note_queue.pop_front()


func _on_timeout(note: BaseNote) -> void:
	if note_queue.is_empty():
		return
	if note_queue[0] != note:
		return
	_handle_judge_result(Judge.JudgeResult.MISS)
	


func _on_expired(note: Rapid) -> void:
	if note_queue.is_empty():
		return
	if note_queue[0] != note:
		return
	note.queue_free()
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
			if note.type == BaseNote.Type.RAPID:
				note.expired.connect(_on_expired)
			else:
				note.timeout.connect(_on_timeout)
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
	print("====== GameResult ======")
	print("score:", game_result.score)
	print("max combo:", game_result.max_combo)
	print("perfect:", game_result.perfect_count)
	print("great:", game_result.great_count)
	print("miss:", game_result.miss_count)
	GameManager.last_result = game_result
	get_tree().change_scene_to_file("res://Scene/UI/result_scene.tscn")


"""暂停按钮，同ESC"""
func _on_pause() -> void:
	pause_layer.pause()
