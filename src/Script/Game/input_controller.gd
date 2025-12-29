extends Node
class_name InputController

signal left_click()
signal right_click()
signal left_release()
signal right_release()
signal left_hold_release(duration: float)
signal right_hold_release(duration: float)

# 长按阈值，ms单位
@export var long_press_threshold: float = 500

var left_press_time: int = 0
var right_press_time: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		left_press_time = Time.get_ticks_msec()
		left_click.emit()
	if event.is_action_released("left"):
		var duration: int = Time.get_ticks_msec() - left_press_time
		if duration < long_press_threshold:
			left_release.emit()
		else:
			left_hold_release.emit(float(duration) / 1000)
	
	if event.is_action_pressed("right"):
		right_press_time = Time.get_ticks_msec()
		right_click.emit()
	if event.is_action_released("right"):
		var duration: int = Time.get_ticks_msec() - right_press_time
		if duration < long_press_threshold:
			right_release.emit()
		else:
			right_hold_release.emit(float(duration) / 1000)
