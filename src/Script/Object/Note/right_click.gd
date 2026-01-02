class_name RightClick
extends BaseNote


func _process(_delta: float) -> void:
	if current_time > timestamp + DEAD_TIMESTAMP:
		timeout.emit(self)
