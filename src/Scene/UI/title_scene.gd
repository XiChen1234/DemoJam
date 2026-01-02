extends Control

@onready var main_button: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/MainButton
@onready var option_button: GridContainer = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var back: TextureButton = $Back

@onready var button_array: Array[TextureButton] = [
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Start, 
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Option, 
	$MarginContainer/VBoxContainer/HBoxContainer/MainButton/Quit
]

@onready var volume_slider: HSlider = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton/VolumeSlider
@onready var button_en: Button = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton/HBoxContainer/ButtonEN
@onready var button_zh_cn: Button = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton/HBoxContainer/ButtonZH_CN


func _ready() -> void:
	button_array[0].pivot_offset = button_array[0].size / 2
	button_array[1].pivot_offset = button_array[1].size / 2
	button_array[2].pivot_offset = button_array[2].size / 2



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


"""开始按钮"""
func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")


"""设置按钮"""
func _on_options() -> void:
	main_button.visible = false
	option_button.visible = true
	back.visible = true
	
	var config: PlayerConfig = GameManager.player_config
	volume_slider.value = config.volume * 100
	match config.language:
		PlayerConfig.Language.EN:
			button_en.button_pressed = true
		PlayerConfig.Language.ZH_CN:
			button_zh_cn.button_pressed = true


"""退出按钮"""
func _on_quit() -> void:
	get_tree().quit()


"""设置界面的返回按钮"""
func _on_back() -> void:
	GameManager.save_config()
	
	main_button.visible = true
	option_button.visible = false
	back.visible = false


"""设置界面的配置控件"""
func _on_volume_change(value: float) -> void:
	print(value)
	var v: float = value / 100
	GameManager.player_config.volume = v
	AudioServer.set_bus_volume_db(
		0,
		linear_to_db(v)
	)


func _on_language_changed(language: int) -> void:
	print(language)
	match language:
		0:
			GameManager.player_config.language = PlayerConfig.Language.EN
			TranslationServer.set_locale("en")
		1:
			GameManager.player_config.language = PlayerConfig.Language.ZH_CN
			TranslationServer.set_locale("zh_CN")
