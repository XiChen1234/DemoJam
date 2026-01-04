extends Control
class_name VideoLayer

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var skip: Button = $Skip

@export var video_stream: VideoStream
# 下一个场景
@export var next_scene: PackedScene


func _ready() -> void:
	GameManager.pause_bgm()
	if video_stream:
		video_stream_player.stream = video_stream
	video_stream_player.play()


"""去往下一个场景"""
func _goto_next_scene() -> void:
	GameManager.resume_bgm()
	
	if next_scene:
		# 实例化新场景
		var new_scene = next_scene.instantiate()
		# 替换当前场景
		if get_tree().current_scene:
			get_tree().current_scene.queue_free()
		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene


"""
视频播放结束
"""
func _on_video_finished() -> void:
	_goto_next_scene()


"""跳过"""
func _on_skip() -> void:
	if video_stream_player.is_playing():
		video_stream_player.stop()
	_goto_next_scene()
