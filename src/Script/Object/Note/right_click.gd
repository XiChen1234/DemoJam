class_name RightClick
extends BaseNote


func _process(_delta: float) -> void:
	if position.x < deadline:
		note_destroy.emit()
