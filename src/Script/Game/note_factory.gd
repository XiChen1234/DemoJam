class_name NoteFactory
extends Node


const NOTE_SCENES: Array= [
	preload("res://Scene/Object/Note/left_click.tscn"),
	preload("res://Scene/Object/Note/right_click.tscn"),
	preload("res://Scene/Object/Note/left_hold.tscn"),
	preload("res://Scene/Object/Note/right_hold.tscn"),
	preload("res://Scene/Object/Note/rapid.tscn"),
]


"""根据类型参数创建音符的基础函数"""
static func create_note(data: Dictionary) -> BaseNote:
	var scene: PackedScene = NOTE_SCENES[data.get("type")]
	var note: BaseNote = scene.instantiate()
	note.init_config(data)
	return note
