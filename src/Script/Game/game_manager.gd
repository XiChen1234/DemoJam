extends Node

enum Language {
	English, 简体中文
}

# 玩家配置数据
var master_volume: float = 1.0
var language: Language = Language.简体中文

# 关卡数据
var selected_level: LevelData
# 结算得分数据
var last_result: Variant = {}

# 测试用，后删
var test_mode: bool = false
var json_path: String = ""
var music_path: String = ""
