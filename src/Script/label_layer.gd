extends Node
class_name LabelLayer

@export var cat: Cat
@export var result_label: PackedScene

enum ResultType {
	PERFECT, GREAT, MISS,
	HOLD,
	RAPID,
}


"""根据等级生成label"""
func spawn_result(type: ResultType) -> void:
	var label: ResultLabel = result_label.instantiate()
	label.global_position = _get_random_pos()
	add_child(label)
	label.play(type)

func _get_random_pos() -> Vector2:
	var base = cat.global_position
	return base + Vector2(
		randf_range(0, 300),
		randf_range(-200, 200)
	)
