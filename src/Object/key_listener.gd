extends Sprite2D

@export var key_name: String = ""
@onready var music_key := preload("res://Object/music_key.tscn")
@onready var score_text := preload("res://Object/score_text.tscn")
@onready var random_spawn_timer: Timer = $RandomSpawnTimer

var music_key_queue = []

# 控制不同表现判定与得分
var perfect_press_threshold: float = 30
var good_press_threshold:float = 50
var ok_press_threshold:float = 80

var perfect_press_score:float = 250
var good_press_score:float = 100
var ok_press_score:float = 20

func _process(delta: float) -> void:
	# 当队列中存在下落音符的时候
	if music_key_queue.size() > 0:
		# 清除已经过期的音符
		if music_key_queue.front().has_passed:
			music_key_queue.pop_front()
			
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.global_position = global_position
			st_inst.set_text_info("MISS")
			Signals.reset_combo.emit()
			
		# 处理输入函数
		if Input.is_action_just_pressed(key_name):
			var key_to_pop = music_key_queue.pop_front()
			
			var distance_from_pass = abs(key_to_pop.pass_threshold - key_to_pop.global_position.x)
			print(distance_from_pass)
			var press_text: String = ""
			if distance_from_pass < perfect_press_threshold:
				print("perfect")
				press_text = "PERFECT"
				Signals.increase_score.emit(perfect_press_score)
				Signals.increase_combo.emit()
			elif distance_from_pass < good_press_threshold:
				press_text = "GOOD"
				print("good")
				Signals.increase_score.emit(good_press_score)
				Signals.increase_combo.emit()
			else:
				press_text = "MISS"
				print("miss")
				Signals.reset_combo.emit()
			
			key_to_pop.queue_free()
			
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.global_position = global_position
			st_inst.set_text_info(press_text)
		
func create_music_key():
	var mk_inst = music_key.instantiate()
	get_tree().get_root().call_deferred("add_child", mk_inst)
	mk_inst.set_up(position.y)
	
	music_key_queue.push_back(mk_inst)


func _on_random_spawn() -> void:
	create_music_key()
	random_spawn_timer.wait_time = randf_range(0.4, 3)
	random_spawn_timer.start()
