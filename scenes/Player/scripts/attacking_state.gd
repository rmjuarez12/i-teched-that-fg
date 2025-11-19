extends PlayerState

@export var ground_state: PlayerState
@export var attack_timer: Timer

var attack_type: String

func on_enter() -> void:
	attack_timer.start()

	if attack_type == "l_attack_1":
		bg_light_grab()

func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	next_state = ground_state

# Big guy moveset
func bg_light_grab():
	attack_timer.wait_time = 0.2
	character.velocity.x = 700 if character.is_facing_right else -700