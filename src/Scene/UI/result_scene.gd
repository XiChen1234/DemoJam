extends Control

enum Rank {
	S, A, B, C, D
}
const RankText: Dictionary[Rank, String] = {
	Rank.S: "Super",
	Rank.A: "A",
	Rank.B: "B",
	Rank.C: "C",
	Rank.D: "D",
}

@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var perfect_label: Label = $PerfectLabel
@onready var great_label: Label = $GreatLabel
@onready var miss_label: Label = $MissLabel
@onready var rank_label: Label = $RankLabel


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
	rank_label.text = "Rank: %s" % RankText[_calculate_rank(result)] 


"""计算评级函数"""
func _calculate_rank(result: GameResult) -> Rank:
	var total_notes := result.perfect_count \
		+ result.great_count \
		+ result.miss_count

	if total_notes == 0:
		return Rank.D

	var accuracy := float(result.perfect_count * 2 + result.great_count) \
		/ float(total_notes * 2)

	if accuracy >= 0.95:
		return Rank.S
	elif accuracy >= 0.85:
		return Rank.A
	elif accuracy >= 0.70:
		return Rank.B
	elif accuracy >= 0.50:
		return Rank.C
	else:
		return Rank.D


func _on_next() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
