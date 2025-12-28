extends Control

enum LevelState {
	LOCKED,        # 未解锁
	UNLOCKED,      # 已解锁未通关
	CLEARED        # 已通关
}

@onready var done: TextureRect = $Done
@onready var level_name: TextureRect = $LevelName
@onready var icon: TextureRect = $Icon
@onready var button: Button = $Button


func set_state(state: LevelState) -> void:
	match state:
		LevelState.LOCKED:
			pass
		LevelState.UNLOCKED:
			pass
		LevelState.CLEARED:
			pass
