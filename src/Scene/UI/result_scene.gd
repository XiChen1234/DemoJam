extends Control

const CardBackgruondTexture: Array = [
	preload("res://Assert/Art/Result/eden.png"),
	preload("res://Assert/Art/Result/heaven.png"),
	preload("res://Assert/Art/Result/ark.png"),
	preload("res://Assert/Art/Result/acheron.png"),
	preload("res://Assert/Art/Result/world.png"),
]

const RankTexture: Dictionary[GameResult.Rank, Texture] = {
	GameResult.Rank.S: preload("res://Assert/Art/Result/S.png"),
	GameResult.Rank.A: preload("res://Assert/Art/Result/A.png"),
	GameResult.Rank.B: preload("res://Assert/Art/Result/B.png"),
	GameResult.Rank.DEFEAT: preload("res://Assert/Art/Result/defeat.png"),
}

@onready var card_background: TextureRect = $Card/CardBackground
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
	
	var level_id: int = GameManager.selected_level.level_id
	card_background.texture = CardBackgruondTexture[level_id]
	
	
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
	
	rank_rect.texture = RankTexture[result.rank]
	lighting.visible = result.rank != GameResult.Rank.DEFEAT




"""rank的动效"""
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


"""下一关"""
func _on_next() -> void:
	GameManager.play_button_sound()
	GameManager.commit_result()
	
	if GameManager.selected_level.level_id == 4 and \
	GameManager.last_result.rank != GameResult.Rank.DEFEAT and \
	not GameManager.player_config.watched_ending:
		
		var video_layer: VideoLayer = preload(
			"res://Scene/Video/video_layer.tscn"
		).instantiate()
		video_layer.video_stream = preload("res://Assert/Video/end.ogv")
		video_layer.next_scene = preload("res://Scene/UI/select_level.tscn")
		
		get_tree().root.add_child(video_layer)
		
		video_layer.skip.pressed.connect(func():
			GameManager.player_config.watched_ending = true
			GameManager.save_config()
		)
		video_layer.video_stream_player.finished.connect(func():
			GameManager.player_config.watched_ending = true
			GameManager.save_config()
		)
	else:
		get_tree().change_scene_to_file("res://Scene/UI/select_level.tscn")
