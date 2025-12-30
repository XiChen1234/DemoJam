extends Node2D
class_name ResultLabel

@onready var label: Label = $Label
const FLOAT_UP := Vector2(0, -40)


"""label播放tween动画"""
func play(type: LabelLayer.ResultType) -> void: 
	_setup_style(type)
	_play_tween(type)

func _setup_style(type: LabelLayer.ResultType) -> void:
	match type:
		LabelLayer.ResultType.MISS:
			label.text = "Miss"
			label.modulate = Color(0.7, 0.7, 0.7)
			label.scale = Vector2.ONE

		LabelLayer.ResultType.GREAT:
			label.text = "Great"
			label.modulate = Color(1.0, 0.8, 0.3)
			label.scale = Vector2.ONE

		LabelLayer.ResultType.PERFECT:
			label.text = "Perfect"
			label.modulate = Color(1.0, 0.95, 0.6)
			label.scale = Vector2(1.2, 1.2)

		LabelLayer.ResultType.RAPID:
			label.text = "Rapid"
			label.modulate = Color.CYAN

		LabelLayer.ResultType.HOLD:
			label.text = "Excellent"
			label.modulate = Color(0.6, 1.0, 0.6)


func _play_tween(type: int) -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# 向上漂浮
	tween.tween_property(
		self,
		"position",
		position + FLOAT_UP,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# 渐隐
	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.4
	)

	# Perfect 的额外“弹一下”
	if type == LabelLayer.ResultType.PERFECT:
		label.scale = Vector2(0.6, 0.6)
		tween.tween_property(
			label,
			"scale",
			Vector2.ONE,
			0.2
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.finished.connect(queue_free)
