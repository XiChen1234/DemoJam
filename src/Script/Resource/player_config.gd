extends Resource
class_name PlayerConfig

enum Language {
	EN, ZH_CN
}

@export var done_level: int = -1 # 已通关id
@export var score_history: Array = []

@export_range(0.0, 1.0, 0.01)
var volume: float = 1
@export var language: Language = Language.EN # 你来补充语言设置的具体格式，当前只有：英文、简体中文
