extends Node2D

@onready var game_ui: Control = $GameUI
@onready var cat: Node2D = $Cat
@onready var music_game_area: Node2D = $MusicGameArea

func _ready() -> void:
	get_tree().paused = true
	
	game_ui.connect("left_press", cat.start_hit.bind())
	game_ui.connect("left_click", cat.stop.bind())
	game_ui.connect("left_long_press", cat.stop.bind())
	game_ui.connect("right_press", cat.start_ha.bind())
	game_ui.connect("right_click", cat.stop.bind())
	game_ui.connect("right_long_press", cat.stop.bind())
	
	game_ui.connect("left_press", music_game_area.left_click.bind())
	game_ui.connect("right_press", music_game_area.right_click.bind())
	game_ui.connect("left_long_press", music_game_area.left_long_press.bind())
	game_ui.connect("right_long_press", music_game_area.right_long_press.bind())
