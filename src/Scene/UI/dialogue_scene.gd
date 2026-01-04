extends Control
class_name DialogueScene

@onready var background: TextureRect = $Background
@onready var header_left: TextureRect = $HeaderLeft
@onready var header_right: TextureRect = $HeaderRight

@onready var name_label: Label = $MarginContainer/Panel/VBoxContainer/NameLabel
@onready var text_label: Label = $MarginContainer/Panel/VBoxContainer/TextLabel

@onready var button_list: VBoxContainer = $ButtonList
@onready var buttons: Array[Button] = [
	$ButtonList/Button1,
	$ButtonList/Button2,
	$ButtonList/Button3
]
@onready var next: Button = $Next

var dialogue_data: DialogueData = DialogueData.new()
# 当前对话索引
var current_index: int = 0


func _ready() -> void:
	var level_data: LevelData = GameManager.selected_level
	background.texture = level_data.background
	header_right.texture = level_data.npc
	header_right.visible = false
	
	_load_dialogue_data(level_data.dialogue_json)
	current_index = 0
	_show_current_line()


"""
加载关卡对话数据
- dialogue_json: 在关卡内资源配置的对话资源路径
"""
func _load_dialogue_data(dialogue_json: String) -> void:
	var file: FileAccess = FileAccess.open(dialogue_json, FileAccess.READ)
	if not file:
		push_error("Dialogue json not found: " + dialogue_json)
		return
	
	var json = JSON.parse_string(file.get_as_text())
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



"""结束对话"""
func _end_dialogue() -> void:
	print("finsih")


"""重置文本状态"""
func _reset_ui() -> void:
	text_label.visible = false
	button_list.visible = false
	header_left.visible = false
	header_right.visible = false


"""重新渲染文本/界面"""
func _render_line(line: DialogueLine) -> void:
	# 渲染头像
	var speaker: String = line.speaker
	header_left.visible = (speaker == "player")
	header_right.visible = (speaker == "npc")
	# 渲染名称
	name_label.text = line.name
	# 渲染文本
	if line.line_type == "text":
		_render_text(line)
	else:
		_render_options(line)


func _render_text(line: DialogueLine) -> void:
	next.visible = true
	text_label.text = line.text
	text_label.visible = true


func _render_options(line: DialogueLine) -> void:
	next.visible = false
	button_list.visible = true
	for i in buttons.size():
		buttons[i].text = line.options[i]


func _on_next() -> void:
	_next_line()


"""对话推进下一条"""
func _next_line() -> void:
	current_index += 1
	_show_current_line()
