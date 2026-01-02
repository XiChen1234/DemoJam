extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String

@export_file("*.json") var json_path: String
@export_file("*.ogg", "*.wav", "*.mp3") var music_path: String
