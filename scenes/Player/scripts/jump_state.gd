extends PlayerState

@export var falling_state: PlayerState

# Called every frame. 'delta' is the elapsed time since the previous frame.
func state_process(_delta: float) -> void:
	if character.velocity.y > 0:
		next_state = falling_state