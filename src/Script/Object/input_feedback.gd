extends Control
class_name InputFeedback

@export var cat: Cat
@onready var left_beat_button: BeatButton = $LeftBeatButton
@onready var right_beat_button: BeatButton = $RightBeatButton

func on_left_pressed(): 
	cat.set_state(Cat.State.HIT)
	left_beat_button.press()
	
func on_left_released(): 
	cat.set_state(Cat.State.IDLE)
	left_beat_button.release()

func on_right_pressed(): 
	cat.set_state(Cat.State.HA)
	right_beat_button.press()

func on_right_released(): 
	cat.set_state(Cat.State.IDLE)
	right_beat_button.release()
