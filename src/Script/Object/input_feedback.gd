extends Node2D
class_name InputFeedback

@export var cat: Cat
@export var beat_button: BeatButton

func on_left_pressed(): 
	cat.start_hit()
	
func on_left_released(): 
	cat.stop()

func on_right_pressed(): 
	cat.start_ha()

func on_right_released(): 
	cat.stop()
