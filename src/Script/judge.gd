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
