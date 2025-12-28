class_name RightClick
extends BaseNote


func _process(delta: float) -> void:
	super(delta)
	if position.x < deadline:
		note_destroy.emit()
