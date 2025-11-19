extends PlayerState

@export var ground_state: PlayerState
@export var dash_timer: Timer

func on_enter() -> void:
	dash_timer.start()
	character.velocity.x = 100 if character.is_facing_right else -100

func _on_f_dash_timer_timeout() -> void:
	dash_timer.stop()
	next_state = ground_state
