extends Control

signal left_press # 按下（只要按下就行）
signal left_click # 短按释放
signal left_long_press(duration) # 长按释放
signal right_press
signal right_click
signal right_long_press(duration)

var long_press_threshold: float = 0.5  # 长按阈值（秒） 
var left_pressed_time: float = 0
var right_pressed_time: float = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		left_pressed_time = Time.get_ticks_msec() / 1000.0  # 记录按下时间
		emit_signal("left_press")
	
	if event.is_action_released("left"):
		# 记录持续时间
		var duration = Time.get_ticks_msec() / 1000.0 - left_pressed_time
		if duration >= long_press_threshold:
			emit_signal("left_long_press", duration)
		else:
			emit_signal("left_click")
	
	if event.is_action_pressed("right"):
		right_pressed_time = Time.get_ticks_msec() / 1000.0  # 记录按下时间
		emit_signal("right_press")
	
	if event.is_action_released("right"):
		# 记录持续时间
		var duration = Time.get_ticks_msec() / 1000.0 - right_pressed_time
		if duration >= long_press_threshold:
			emit_signal("right_long_press", duration)
		else:
			emit_signal("right_click")
