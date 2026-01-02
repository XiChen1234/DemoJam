extends Resource
class_name GameResult

signal score_changed(score: int)
signal combo_changed(current_combo: int)

const SCORE_TABLE: Array[int] = [
	1000,	# perfect
	500,	# great
	800,	# hold
	50		# rapid
]

var score: int = 0

var current_combo: int = 0
var max_combo: int = 0

var perfect_count: int = 0
var great_count: int = 0
var miss_count: int = 0

"""
判定结果计数方法
- result: 最终判定结果
- score_table: 存储各结果对应分值的表
"""
func apply_judge_result(result: Judge.JudgeResult) -> void:
	match result:
		Judge.JudgeResult.MISS:
			miss_count += 1
			current_combo = 0

		Judge.JudgeResult.PERFECT:
			perfect_count += 1
			score += SCORE_TABLE[0]
			_add_combo()

		Judge.JudgeResult.GREAT:
			great_count += 1
			score += SCORE_TABLE[1]
			_add_combo()

		Judge.JudgeResult.HOLD_OK:
			score += SCORE_TABLE[2]
			_add_combo()

		Judge.JudgeResult.RAPID_HIT:
			score += SCORE_TABLE[3]
			_add_combo()
	
	score_changed.emit(score)
	combo_changed.emit(current_combo)

func _add_combo() -> void:
	current_combo += 1
	if current_combo > max_combo:
		max_combo = current_combo
