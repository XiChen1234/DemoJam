extends Resource
class_name PlayerConfig

enum Language {
	EN, ZH_CN
}

@export var done_level: int = -1 # 已通关id
@export var dialogue_level: int = -1 # 已看过剧情id
@export var score_history: Array = []

@export_range(0.0, 1.0, 0.01)
var volume: float = 1
@export var language: Language = Language.EN

"""
是否看过开场视频/结尾视频：
- 看过开场视频
- 看过结尾视频
"""
@export var watched_opening: bool = false
@export var watched_ending: bool = false
@export var is_teached: bool = false
