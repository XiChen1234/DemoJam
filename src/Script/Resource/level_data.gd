extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String
@export var background: Texture
@export var npc: Texture

@export_file("*.json") var timeline_json: String
@export_file("*.ogg", "*.wav", "*.mp3") var music_path: String

@export_file("*.json") var dialogue_json: String
