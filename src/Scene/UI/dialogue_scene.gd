extends Control
class_name DialogueScene

@onready var background: TextureRect = $Background
@onready var header_left: TextureRect = $HeaderLeft
@onready var header_right: TextureRect = $HeaderRight

@onready var name_label: Label = $MarginContainer/Control/Panel/VBoxContainer/Name
@onready var text_label: Label = $MarginContainer/Control/Panel/VBoxContainer/Text

@onready var button_list: VBoxContainer = $ButtonList
@onready var button_labels: Array[Label] = [
	$ButtonList/Button1/Label,
	$ButtonList/Button2/Label,
	$ButtonList/Button3/Label,
]
@onready var next: TextureButton = $Next

var dialogue_data: DialogueData = DialogueData.new()
# 当前对话索引
var current_index: int = 0

# 实现打字机效果
var writer_speed: float = 30
var typing_tween: Tween = null
var is_typing: bool = false


func _ready() -> void:
	var level_data: LevelData = GameManager.selected_level
	background.texture = level_data.background
	header_right.texture = level_data.npc
	
	# 初始状态：两个人物都灰化
	header_left.modulate = Color(0.5,0.5,0.5,1)
	header_right.modulate = Color(0.5,0.5,0.5,1)
	header_left.visible = true
	header_right.visible = true
	
	_load_dialogue_data(level_data.dialogue_json)
	current_index = 0
	_show_current_line()


func _input(event: InputEvent) -> void:
	if dialogue_data.lines[current_index].line_type == "options":
		return  
	if event.is_action_pressed("right") or event.is_action_pressed("left"):
		_next_line()


"""
加载关卡对话数据
- dialogue_json: 在关卡内资源配置的对话资源路径
"""
func _load_dialogue_data(dialogue_json: String) -> void:
	# 检查文件是否存在
	if not FileAccess.file_exists(dialogue_json):
		push_error("Dialogue json not found: " + dialogue_json)
		return
	
	var file: FileAccess = FileAccess.open(dialogue_json, FileAccess.READ)
	var text: String = file.get_as_text()
	var json = JSON.parse_string(text)
	if json == null:
		push_error("Invalid JSON")
		return
	
	var json_data: Dictionary = json
	dialogue_data.id = json_data.get("id")
	
	for line_data: Dictionary in json_data.get("lines"):
		var line: DialogueLine = DialogueLine.new()
		line.speaker = line_data.get("speaker")
		line.name = line_data.get("name")
		var type: String = line_data.get("type")
		line.line_type = type
		if type == "text":
			line.text = line_data.get("text")
		else:
			line.options = line_data.get("options")
		
		dialogue_data.lines.append(line)


"""显示对话"""
func _show_current_line() -> void:
	if current_index >= dialogue_data.lines.size():
		_end_dialogue()
		return

	_reset_ui()
	var line: DialogueLine = dialogue_data.lines[current_index]
	_render_line(line)
	_highlight_speaker(line.speaker)


func _highlight_speaker(speaker: String) -> void:
	if speaker == "player":
		header_left.modulate = Color(1,1,1,1)
		header_right.modulate = Color(0.5,0.5,0.5,1)
	elif speaker == "npc":
		header_right.modulate = Color(1,1,1,1)
		header_left.modulate = Color(0.5,0.5,0.5,1)


func _fade_out_prev_speaker() -> void:
	if current_index == 0:
		return
	var prev_line: DialogueLine = dialogue_data.lines[current_index - 1]
	var tween = create_tween()
	var target
	if prev_line.speaker == "player":
		target = header_left
	else:
		target = header_right
	tween.tween_property(target, "modulate", Color(0.5,0.5,0.5,1), 0.3)
	tween.finished.connect("_on_characters_faded")


"""结束对话"""
func _end_dialogue() -> void:
	var level_index: int = GameManager.selected_level.level_id
	if GameManager.player_config.dialogue_level < level_index:
		GameManager.player_config.dialogue_level = level_index
		GameManager.save_config()
	
	_end()


"""重置文本状态"""
func _reset_ui() -> void:
	text_label.visible = false
	text_label.visible_ratio = 0
	button_list.visible = false


"""人物缩小灰化动画（上一条淡出）"""
func _fade_out_characters() -> void:
	if current_index >= dialogue_data.lines.size():
		_end_dialogue()
		return
	
	var tween := create_tween()

	# 上一条说话者灰化
	if current_index > 0:
		var prev_line: DialogueLine = dialogue_data.lines[current_index - 1]
		if prev_line.speaker == "player":
			tween.tween_property(header_left, "modulate", Color(0.5,0.5,0.5,1), 0.3)
		elif prev_line.speaker == "npc":
			tween.tween_property(header_right, "modulate", Color(0.5,0.5,0.5,1), 0.3)

	tween.finished.connect(_on_characters_faded)



"""Tween结束后的回调（显示下一条并渐显高亮）"""
func _on_characters_faded() -> void:
	if current_index >= dialogue_data.lines.size():
		_end_dialogue()
		return
	
	_show_current_line()

	# 当前说话者平滑高亮
	var line: DialogueLine = dialogue_data.lines[current_index]
	var tween := create_tween()
	if line.speaker == "player":
		tween.tween_property(header_left, "modulate", Color(1,1,1,1), 0.3)
	elif line.speaker == "npc":
		tween.tween_property(header_right, "modulate", Color(1,1,1,1), 0.3)


"""重新渲染文本/界面"""
func _render_line(line: DialogueLine) -> void:
	name_label.text = line.name

	header_left.visible = true
	header_right.visible = true

	if line.line_type == "text":
		_render_text(line)
	else:
		_render_options(line)

	# 当前说话者平滑高亮
	var tween := create_tween()
	if line.speaker == "player":
		tween.tween_property(header_left, "modulate", Color(1,1,1,1), 0.3)
	elif line.speaker == "npc":
		tween.tween_property(header_right, "modulate", Color(1,1,1,1), 0.3)


func _render_text(line: DialogueLine) -> void:
	next.visible = true
	var tr_text: String = tr(line.text)
	text_label.text = tr_text
	text_label.visible = true
	text_label.visible_ratio = 0
	_start_writer_effect(tr_text)


"""开始tween"""
func _start_writer_effect(text: String) -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween = null

	is_typing = true
	
	var duration: float = max(1, text.length() / writer_speed)
	typing_tween = create_tween()
	typing_tween.tween_property(text_label, "visible_ratio", 1, duration)
	
	typing_tween.finished.connect(_finished_writer_effect)


"""tween结束的回调"""
func _finished_writer_effect() -> void:
	if typing_tween:
		typing_tween.kill()
	is_typing = false
	text_label.visible_ratio = 1.0


func _render_options(line: DialogueLine) -> void:
	next.visible = false
	button_list.visible = true
	for i in range(button_labels.size()):
		button_labels[i].text = tr(line.options[i])


"""对话推进下一条"""
func _next_line() -> void:
	GameManager.play_button_sound()
	if is_typing:
		_finished_writer_effect()
		return
	
	current_index += 1
	# 先播放上一条缩小灰化动画，再显示下一条
	_fade_out_characters()


"""点击next按钮"""
func _on_next_input(event: InputEvent) -> void:
	GameManager.play_button_sound()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_next_line()


"""跳过按钮"""
func _on_skip() -> void:
	GameManager.play_button_sound()
	_end()


func _end() -> void:
	if not GameManager.player_config.is_teached:
		get_tree().change_scene_to_file("res://Scene/UI/teached_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://Scene/Game/game_scene.tscn")


"""返回按钮"""
func _on_back() -> void:
	GameManager.play_button_sound()
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
