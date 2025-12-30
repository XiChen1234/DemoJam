extends Node
class_name Judge

signal note_miss
signal note_great
signal note_perfect
signal rapid_hit
signal note_hold

enum Level {
	PERFECT, GREAT, MISS
}

const LEVEL_TIMESTAMP: Dictionary[Level, float] = {
	Level.PERFECT: 0.05,
	Level.GREAT: 0.1,
	Level.MISS: 0.15,
}

enum JudgeResult {
	NONE,       # 完全不在判定区间（diff > MISS）
	MISS,
	GREAT,
	PERFECT,
	HOLD_OK,    # 长按成功
	RAPID_HIT,
}
enum SideInput {
	LEFT, RIGHT
}


"""单击 / 长按开始"""
func judge_press(
	current_time: float, note: BaseNote, side: SideInput
) -> JudgeResult:
	if not _match_side(note.type, side):
		return JudgeResult.NONE
	
	var diff: float = abs(current_time - note.timestamp)
	if diff > LEVEL_TIMESTAMP[Level.MISS]:
		return JudgeResult.NONE

	if diff > LEVEL_TIMESTAMP[Level.GREAT]:
		return JudgeResult.MISS

	if diff > LEVEL_TIMESTAMP[Level.PERFECT]:
		return JudgeResult.GREAT

	return JudgeResult.PERFECT


"""长按释放"""
func judge_hold_release(
	current_time: float, note: BaseNote, side: SideInput
) -> JudgeResult:
	if not _match_side(note.type, side):
		return JudgeResult.NONE
	
	var end_time: float = note.timestamp + note.duration
	var diff: float = current_time - end_time
	
	if diff > LEVEL_TIMESTAMP[Level.MISS]:
		return JudgeResult.NONE
	
	if diff < -LEVEL_TIMESTAMP[Level.GREAT]:
		return JudgeResult.MISS
	
	# 有点怂小小防御一手
	if not is_instance_valid(note):
		return JudgeResult.NONE
	
	return JudgeResult.HOLD_OK


"""连击"""
func judge_rapid(current_time: float, note: BaseNote) -> JudgeResult:
	var start: float = note.timestamp
	var end: float = note.timestamp + note.duration

	# 只在 Great 窗口内有效
	if current_time < start - LEVEL_TIMESTAMP[Level.GREAT]:
		return JudgeResult.NONE
	if current_time > end + LEVEL_TIMESTAMP[Level.GREAT]:
		return JudgeResult.NONE

	return JudgeResult.RAPID_HIT


"""
判断是否匹配方向
type: 音符种类
side: 左右
"""
func _match_side(type: BaseNote.Type, side: SideInput) -> bool:
	match type:
		BaseNote.Type.LEFT_CLICK, BaseNote.Type.LEFT_HOLD:
			return side == SideInput.LEFT
		BaseNote.Type.RIGHT_CLICK, BaseNote.Type.RIGHT_HOLD:
			return side == SideInput.RIGHT
		_:
			return false



# ========================重构分界线，上重构，下原码==================================

"""判定点击逻辑"""
func judge_click(
	current_time: float, 
	type: BaseNote.Type, 
	note: BaseNote
) -> void:
	var timestamp: float = note.timestamp
	"""
	检测连打
	对于连打，在时间窗口内检测命中，命中即加分；结尾不给时间窗口
	"""
	if type == BaseNote.Type.RAPID:
		if current_time < timestamp - LEVEL_TIMESTAMP[Level.GREAT]:
			return
		if current_time > timestamp + note.duration + LEVEL_TIMESTAMP[Level.GREAT]:
			return
		rapid_hit.emit()
		return
	
	"""检测长按期间的输入信号"""
	if type == BaseNote.Type.LEFT_HOLD or type == BaseNote.Type.RIGHT_HOLD:
		if current_time > timestamp + LEVEL_TIMESTAMP[Level.MISS]:
			note_miss.emit()
	
	var diff = abs(current_time - timestamp)
	"""检测其他音符：单击、长按开始"""
	if diff > LEVEL_TIMESTAMP[Level.MISS]:
		return
	elif diff > LEVEL_TIMESTAMP[Level.GREAT]:
		note_miss.emit()
	elif diff > LEVEL_TIMESTAMP[Level.PERFECT]:
		note_great.emit()
	else:
		note_perfect.emit()


"""判定长按释放逻辑"""
func judge_hold(
	current_time: float,
	note: BaseNote
) -> void:
	var timestamp = note.timestamp + note.duration
	var diff = abs(current_time - timestamp)
	
	if diff > LEVEL_TIMESTAMP[Level.MISS]:
		note_miss.emit()
	else:
		note_hold.emit()
