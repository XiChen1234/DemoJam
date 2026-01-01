class_name Cat
extends Node2D

enum State {
	IDLE, HIT, HA
}

var _currnet_state: State = State.IDLE

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func set_state(state: State) -> void:
	if _currnet_state == state:
		return

	_currnet_state = state
	_play_state_animation()


func _play_state_animation() -> void:
	match _currnet_state:
		State.IDLE:
			animated_sprite_2d.play("idle")
		State.HIT:
			animated_sprite_2d.play("hit")
		State.HA:
			animated_sprite_2d.play("ha")
