extends Control

@export var level_data: Array[LevelData]
@export var level_button: Array[LevelButton]
 

func _ready() -> void:
	GameManager.start_bgm()
	var done_level = GameManager.player_config.done_level
	for i in range(level_button.size()):
		var button: LevelButton = level_button[i]
		if i <= done_level:
			button.set_state(LevelButton.State.DONE)
		elif i == done_level + 1:
			button.set_state(LevelButton.State.UNLOCKED)
		else: 
			button.set_state(LevelButton.State.LOCKED)
		# 绑定按钮发来的点击事件信号
		button.select_level.connect(_on_level_select)


func _on_back() -> void:
	GameManager.play_button_sound()
	get_tree().change_scene_to_file("res://Scene/UI/title_scene.tscn")


func _on_level_select(level_index: int) -> void:
	GameManager.selected_level = level_data[level_index]
	
	# 判断剧情
	if GameManager.player_config.dialogue_level < level_index:
		get_tree().change_scene_to_file("res://Scene/UI/dialogue_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")
