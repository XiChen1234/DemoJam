extends Control

@onready var main_button: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/MainButton
@onready var option_button: GridContainer = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var back: TextureButton = $Back

@onready var button_array: Array[TextureButton] = [
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Start, 
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Option, 
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Quit
]


func _ready() -> void:
	_show_info()
	button_array[0].pivot_offset = button_array[0].size / 2
	button_array[1].pivot_offset = button_array[1].size / 2
	button_array[2].pivot_offset = button_array[2].size / 2


"""开始按钮"""
func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")


"""设置按钮"""
func _on_options() -> void:
	main_button.visible = false
	option_button.visible = true
	back.visible = true


"""退出按钮"""
func _on_quit() -> void:
	get_tree().quit()


"""设置界面的返回按钮"""
func _on_back() -> void:
	main_button.visible = true
	option_button.visible = false
	back.visible = false


"""hover效果"""
func _on_start_mouse_entered(button_id: int) -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		button_array[button_id], \
		"scale", Vector2(1.2, 1.2), 0.2 \
	)


func _on_start_mouse_exited(button_id: int) -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		button_array[button_id], \
		"scale", Vector2.ONE, 0.2 \
	)


"""用于让策划测试外部文件曲谱的功能"""
func _show_info() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("test_levels"):
		dir.make_dir("test_levels")
	$Test/Label.text = "测试曲谱路径： %s" % ProjectSettings.globalize_path("user://test_levels")
	

func _on_test_pressed() -> void:
	# 1. 约定好的测试路径
	var json_path := "user://test_levels/test_song.json"
	var music_path := "user://test_levels/test_music.ogg"

	# 2. 简单校验（防止直接崩）
	if not FileAccess.file_exists(json_path):
		push_error("测试曲谱不存在：" + json_path)
		return

	if not FileAccess.file_exists(music_path):
		push_error("测试音乐不存在：" + music_path)
		return

	# 3. 写入测试上下文
	GameManager.test_mode = true
	GameManager.json_path = json_path
	GameManager.music_path = music_path

	# 4. 进入游戏场景
	get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")
