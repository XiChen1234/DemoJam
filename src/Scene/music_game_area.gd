extends Node2D

@onready var falling_key = preload("res://Scene/falling_key.tscn")
@onready var test_random_fall_key_timer: Timer = $TestRandomFallKeyTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var pool_size: int = 10

var fk_pool: Array[FallingKey] = []
var init_position: Vector2 = Vector2(2100, 200)

# test: 随机时间计时器
@export var spawn_time: Vector2 = Vector2(0.5, 1.5)


func _ready() -> void:
	audio_stream_player.play()
	
	initialize_pool()
	set_random_timer()


func get_music_time() -> float:
	return audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()


func left_click():
	var timestamp = get_music_time()
	print("左键单击 - 音乐时间戳: %f 秒" % [timestamp])


func right_click():
	var timestamp = get_music_time()
	print("右键单击 - 音乐时间戳: %f 秒" % [timestamp])


func left_long_press(duration: float):
	var timestamp = get_music_time()
	print("左键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


func right_long_press(duration: float):
	var timestamp = get_music_time()
	print("右键长按 - 时长: %f 秒 - 音乐结束时间戳: %f 秒" % [duration, timestamp])


"""初始化随机时间的计时器"""
func set_random_timer():
	# 生成随机时间间隔
	var timer = randf_range(spawn_time[0], spawn_time[1])
	# 设置定时器的等待时间
	test_random_fall_key_timer.wait_time = timer
	# 重启定时器
	test_random_fall_key_timer.start()


"""Test: demo定时生成音符"""
func _on_create_falling_key() -> void:
	var fk_inst: FallingKey = get_from_pool()
	# 激活
	activate_falling_key(fk_inst)


"""激活对象"""
func activate_falling_key(fk_inst: FallingKey) -> void:
	# 重置音符状态
	fk_inst.visible = true
	fk_inst.set_process(true)
	fk_inst.set_physics_process(true)
	set_random_timer()


"""从对象池中获取对象"""
func get_from_pool() -> FallingKey:
	for fk_inst in fk_pool:
		if not fk_inst.visible:
			return fk_inst
	
	return expand_pool()


"""扩展对象池"""
func expand_pool() -> FallingKey:
	var fk_inst: FallingKey = create_falling_key()
	# 添加到场景和对象池
	add_child(fk_inst)
	fk_pool.append(fk_inst)
	return fk_inst


"""初始化对象池"""
func initialize_pool() -> void:
	for i in range(pool_size):
		var fk_inst: FallingKey = create_falling_key()
		# 添加到场景和对象池
		add_child(fk_inst)
		fk_pool.append(fk_inst)


"""创建音符"""
func create_falling_key() -> FallingKey:
	var fk_inst: FallingKey = falling_key.instantiate()
	fk_inst.set_process(false)
	fk_inst.set_physics_process(false)
	return fk_inst
