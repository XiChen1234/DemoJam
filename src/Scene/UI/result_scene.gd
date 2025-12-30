extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel


func _ready() -> void:
	var data: Variant = GameManager.last_result
	if data.is_empty():
		score_label.text = "Score: --"
		combo_label.text = "Max Combo: --"
		return
	score_label.text = "Score: %d" % data.get("score", 0)
	combo_label.text = "Max Combo: %d" % data.get("max_combo", 0)


func _on_next() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
