extends Resource
class_name GameResult

signal score_changed(score: int)
signal combo_changed(current_combo: int)

"""算分相关"""
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

"""评级相关"""
enum Rank {
	S,
	A,
	B,
	DEFEAT
}
var rank: Rank = Rank.DEFEAT


"""计算评级函数"""
func calculate_rank() -> Rank:
	var total_notes: int = perfect_count + great_count + miss_count

	if total_notes == 0:
		return Rank.DEFEAT

	var accuracy: float = float(perfect_count * 2 + great_count) \
		/ float(total_notes * 2)

	if accuracy >= 0.95:
		return Rank.S
	elif accuracy >= 0.85:
		return Rank.A
	elif accuracy >= 0.60:
		return Rank.B
	else:
		return Rank.DEFEAT


func is_cleared() -> bool:
	return rank != Rank.DEFEAT


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
