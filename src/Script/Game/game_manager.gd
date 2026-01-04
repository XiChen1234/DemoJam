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

func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		player_config = ResourceLoader.load(SAVE_PATH)
	else:
		player_config = PlayerConfig.new()
		ResourceSaver.save(player_config, SAVE_PATH)


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
