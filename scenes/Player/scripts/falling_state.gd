extends PlayerState

@export var landing_state: PlayerState

func state_process(_delta):
	if(character.is_on_floor()):
		next_state = landing_state