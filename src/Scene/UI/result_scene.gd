extends Control

enum Rank {
	S, A, B, DEFEAT
}
const RankTexture: Dictionary[Rank, Texture] = {
	Rank.S: preload("res://Assert/Art/Result/S.png"),
	Rank.A: preload("res://Assert/Art/Result/A.png"),
	Rank.B: preload("res://Assert/Art/Result/B.png"),
	Rank.DEFEAT: preload("res://Assert/Art/Result/defeat.png"),
}

@onready var score_label: Label = $Card/VBoxContainer/VBoxContainer/ScoreLabel
@onready var combo_label: Label = $Card/VBoxContainer/VBoxContainer2/VBoxContainer2/HBoxContainer/ComboLabel
@onready var perfect_label: Label = $Card/VBoxContainer/VBoxContainer2/VBoxContainer3/HBoxContainer2/PerfectLabel
@onready var great_label: Label = $Card/VBoxContainer/VBoxContainer2/VBoxContainer4/HBoxContainer3/GreatLabel
@onready var miss_label: Label = $Card/VBoxContainer/VBoxContainer2/VBoxContainer5/HBoxContainer4/MissLabel
@onready var rank_control: Control = $RankControl
@onready var rank_rect: TextureRect = $RankControl/RankRect
@onready var lighting: TextureRect = $RankControl/Lighting


func _ready() -> void:
	var result: GameResult = GameManager.last_result
	if result == null:
		return
	
	_render_result(result)
	_pop_in()
	if lighting.visible:
		var tween: Tween = create_tween()
		tween.set_loops()  # 无限循环
		tween.tween_property(lighting, "rotation", 2 * PI, 2.0).as_relative() 


"""渲染最后结果"""
func _render_result(result: GameResult) -> void:
	score_label.text = str(result.score)
	combo_label.text = str(result.max_combo)
	perfect_label.text = str(result.perfect_count)
	great_label.text = str(result.great_count)
	miss_label.text = str(result.miss_count)
	
	var rank = _calculate_rank(result)
	rank_rect.texture = RankTexture[rank]
	if rank == Rank.DEFEAT:
		lighting.visible = false


"""计算评级函数"""
func _calculate_rank(result: GameResult) -> Rank:
	var total_notes := result.perfect_count \
		+ result.great_count \
		+ result.miss_count

	if total_notes == 0:
		return Rank.DEFEAT

	var accuracy := float(result.perfect_count * 2 + result.great_count) \
		/ float(total_notes * 2)

	if accuracy >= 0.95:
		return Rank.S
	elif accuracy >= 0.85:
		return Rank.A
	elif accuracy >= 0.60:
		return Rank.B
	else:
		return Rank.DEFEAT


func _pop_in() -> void:
	rank_control.scale = Vector2.ZERO
	rank_control.modulate.a = 1.0

	var tween := create_tween()
	tween.set_parallel(false)

	# ① 冲量放大（极快）
	tween.tween_property(
		rank_control,
		"scale",
		Vector2(1.25, 1.25),
		0.18
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# ② 惯性回弹（压缩）
	tween.tween_property(
		rank_control,
		"scale",
		Vector2(0.92, 0.92),
		0.3
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# ③ 稳定到正常大小
	tween.tween_property(
		rank_control,
		"scale",
		Vector2.ONE,
		0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_next() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
