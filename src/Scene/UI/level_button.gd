extends Control
class_name LevelButton

signal select_level(index: int)

enum State {
	LOCKED, UNLOCKED, DONE
}

@export var icon_locked: Texture
@export var icon_unlock: Texture 
@export var name_locked: Texture 
@export var name_unlock: Texture
@export var name_click: Texture
@export var tick_mark: Texture

@onready var icon: TextureRect = $Icon
@onready var name_label: TextureRect = $NameLabel
@onready var tick: TextureRect = $Tick

var state: State = State.LOCKED
var index: int
@export var level_data: LevelData

var button_size: Vector2


func _ready() -> void:
	"""默认样式"""
	icon.texture = icon_locked
	name_label.texture = name_locked
	tick.texture = tick_mark
	tick.visible = false
	"""初始化自身关卡id"""
	index = level_data.level_id


func set_state(new_state: State) -> void:
	state = new_state
	_update_base_view()


func _update_base_view() -> void:
	match state:
		State.LOCKED:
			icon.texture = icon_locked
			name_label.texture = name_locked
			tick.visible = false
		
		State.UNLOCKED:
			icon.texture = icon_unlock
			name_label.texture = name_unlock
			tick.visible = false
		
		State.DONE:
			icon.texture = icon_unlock
			name_label.texture = name_unlock
			tick.visible = true


func _on_mouse_entered() -> void:
	if state == State.LOCKED:
		return
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, \
		"scale", Vector2(1.1, 1.1), 0.2 \
	)
	name_label.texture = name_click


func _on_mouse_exited() -> void:
	if state == State.LOCKED:
		return
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, \
		"scale", Vector2.ONE, 0.2 \
	)
	name_label.texture = name_unlock


func _gui_input(event: InputEvent) -> void:
	if state == State.LOCKED:
		return
	
	if event is InputEventMouseButton and \
		event.button_index == MOUSE_BUTTON_LEFT and \
		event.is_pressed():
			select_level.emit(index)
