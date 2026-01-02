extends Node

enum Language {
	English, 简体中文
}

# 玩家配置数据
var player_progress: PlayerProgress
var master_volume: float = 1.0
var language: Language = Language.简体中文

# 关卡数据
var selected_level: LevelData
# 结算得分数据
var last_result: GameResult = null

# 测试用，后删
var test_mode: bool = false
var json_path: String = ""
var music_path: String = ""

const SAVE_PATH := "user://save_game.tres"

func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		player_progress = ResourceLoader.load(SAVE_PATH)
	else:
		player_progress = PlayerProgress.new()
		ResourceSaver.save(player_progress, SAVE_PATH)


"""提交存档数据"""
func commit_result() -> void:
	var level_id: int = selected_level.level_id
	if level_id == player_progress.unlock_level:
		player_progress.unlock_level += 1
	
	ResourceSaver.save(player_progress, SAVE_PATH)
