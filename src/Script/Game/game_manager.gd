extends Node

# 玩家配置数据
var player_config: PlayerConfig
# 对话系统数据
var dialogue_data: DialogueData

# 关卡数据
var selected_level: LevelData
# 结算得分数据
var last_result: GameResult = null

const SAVE_PATH := "user://save_game.tres"

var button_click_sound: AudioStream = preload("res://Assert/Audio/SFX/button.mp3")
var _button_player: AudioStreamPlayer
var bgm_stream: AudioStream = preload("res://Assert/Audio/BGM/bgm.mp3")
var _bgm_player: AudioStreamPlayer   
var _current_scene_name: String = ""


func _ready() -> void:
	# 加载玩家数据
	if FileAccess.file_exists(SAVE_PATH):
		player_config = ResourceLoader.load(SAVE_PATH)
	else:
		player_config = PlayerConfig.new()
		ResourceSaver.save(player_config, SAVE_PATH)
	
	# 初始化玩家语言
	match player_config.language:
		PlayerConfig.Language.EN:
			TranslationServer.set_locale("en")
		PlayerConfig.Language.ZH_CN:
			TranslationServer.set_locale("zh_CN")
	
	
	# 初始化按钮音效播放器
	_button_player = AudioStreamPlayer.new()
	add_child(_button_player)
	_button_player.stream = button_click_sound
	_button_player.autoplay = false
	_button_player.bus = "Master"  # 可改成自定义音效总线
	
	# BGM音效播放器
	_bgm_player = AudioStreamPlayer.new()
	add_child(_bgm_player)
	_bgm_player.autoplay = false
	_bgm_player.bus = "Master"      # 可换成 BGM 总线
	_bgm_player.volume_db = linear_to_db(player_config.volume)
	
	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))
	_on_scene_changed(get_tree().current_scene)


"""提交存档数据"""
func commit_result() -> void:
	# ① 没有结算结果，直接返回（安全兜底）"level_name"
	if last_result == null:
		ResourceSaver.save(player_config, SAVE_PATH)
		return
	
	# ② 本关失败，不解锁下一关
	if not last_result.is_cleared():
		ResourceSaver.save(player_config, SAVE_PATH)
		return
	
	# ③ 本关通过，尝试解锁
	
	var level_id: int = selected_level.level_id
	if level_id == player_config.done_level + 1:
		player_config.done_level = level_id
	
	ResourceSaver.save(player_config, SAVE_PATH)


"""保存玩家配置"""
func save_config() -> void:
	ResourceSaver.save(player_config, SAVE_PATH)


"""按钮播放方法"""
func play_button_sound() -> void:
	if _button_player.playing:
		_button_player.stop()
	_button_player.play()


"""按钮设置音量"""
func set_button_volume(volume: float) -> void:
	_button_player.volume_db = linear_to_db(volume)


"""
播放指定BGM
默认是当前BGM
"""
func play_bgm(stream: AudioStream = bgm_stream) -> void:
	if _bgm_player.playing and _bgm_player.stream == stream:
		return
	
	_bgm_player.stream = stream
	_bgm_player.play()


"""暂停"""
func pause_bgm() -> void:
	_bgm_player.stream_paused = true


"""恢复"""
func resume_bgm() -> void:
	_bgm_player.stream_paused = false


"""设置bgm音量"""
func set_bgm_volume(volume: float) -> void:
	_bgm_player.volume_db = linear_to_db(volume)
	player_config.volume = volume


"""场景切换监听函数"""
func _on_scene_changed(new_scene: Node = null) -> void:
	if not new_scene:
		new_scene = get_tree().current_scene
	
	_current_scene_name = new_scene.name
	
	# 哪些场景不播放BGM
	var excluded = ["DialogueScene", "GameScene", "ResultScene", "TeachedScene"]
	
	if _current_scene_name in excluded:
		pause_bgm()
	else:
		play_bgm()
