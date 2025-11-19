extends PlayerState

@export var ground_state: PlayerState
@export var dash_timer: Timer

func on_enter() -> void:
	dash_timer.start()
	character.velocity.x = -70 if character.is_facing_right else 70
	character.velocity.y += -50

func state_process(_delta):
	character.velocity.y += -700 * _delta

func _on_b_dash_timer_timeout() -> void:
	dash_timer.stop()
	next_state = ground_state
