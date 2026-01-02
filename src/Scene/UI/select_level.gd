extends Control

@export var level_data: Array[LevelData]


func _ready() -> void:
	var unlock_level: int = GameManager.player_progress.unlock_level
	for i in range(level_data.size()):
		var state: bool = i <= unlock_level
		_set_state(i, state)


"""
设置按钮状态
- i: 需要设置的关卡id
- state: 关卡状态，true表示解锁，false表示未解锁
"""
func _set_state(i: int, state: bool) -> void:
	level_data[i].is_unlock = state


func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")


func _on_level_select(level_index: int) -> void:
	GameManager.selected_level = level_data[level_index]
	get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")
