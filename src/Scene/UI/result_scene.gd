extends Control

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var perfect_label: Label = $PerfectLabel
@onready var great_label: Label = $GreatLabel
@onready var miss_label: Label = $MissLabel


func _ready() -> void:
	var result: GameResult = GameManager.last_result
	if result == null:
		return
	
	_render_result(result)


"""渲染最后结果"""
func _render_result(result: GameResult) -> void:
	score_label.text = "Score: %d" % result.score
	combo_label.text = "Max Combo: %d" % result.max_combo
	perfect_label.text = "Perfect: %d" % result.perfect_count
	great_label.text = "Great: %d" % result.great_count
	miss_label.text = "Miss: %d" % result.miss_count


func _on_next() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
