extends Sprite2D

@export var speed: float = 1000
@onready var timer: Timer = $Timer
@onready var destroy_timer: Timer = $DestroyTimer

var init_x_pos: float = 1000

var has_passed: bool = false
var pass_threshold = -820

func _init() -> void:
	set_process(false)

func _process(delta: float) -> void:
	global_position -= Vector2(speed * delta, 0)
	# 1.81941403030298
	if global_position.x < pass_threshold and not timer.is_stopped():
		#print("下落时间：%s" % (timer.wait_time -	 timer.time_left))
		timer.stop()
		has_passed = true

func set_up(target_y: float):
	global_position = Vector2(init_x_pos, target_y)
	set_process(true)


func _on_destroy() -> void:
	queue_free()
