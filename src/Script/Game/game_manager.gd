extends Node

# 玩家配置数据
var player_config: PlayerConfig

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
	var level_id: int = selected_level.level_id # 当前关卡的id
	# 判定条件：当前关卡id是已通关id的下一个，即当前id设置为已通关
	if level_id == player_config.done_level + 1:
		player_config.done_level = level_id
	
	ResourceSaver.save(player_config, SAVE_PATH)


"""保存玩家配置"""
func save_config() -> void:
	ResourceSaver.save(player_config, SAVE_PATH)
