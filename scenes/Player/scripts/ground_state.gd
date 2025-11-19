extends PlayerState

@export var jump_speed:float = -400.0

@export var jump_state: PlayerState
@export var attack_state: PlayerState
@export var falling_state: PlayerState
@export var f_dash_state: PlayerState
@export var b_dash_state: PlayerState

func state_process(_delta):
	if not character.is_on_floor():
		next_state = falling_state

func state_input(event : InputEvent):
	if(event.is_action_pressed(character.player_inputs.up) and can_move):
		jump(event)

	var action = character.dispatch_actions()

	print(action)

	if action == "Pretzel" and Input.is_action_just_pressed(character.player_inputs.l):
		next_state = attack_state
		next_state.attack_type = "l_attack_1"
	# elif character.match_motion(character.motion_inputs["FDash"]):
	# 	next_state = f_dash_state
	# elif character.match_motion(character.motion_inputs["BDash"]):
	# 	next_state = b_dash_state

func jump(_event : InputEvent):
	var jump_velocity = jump_speed

	character.velocity.y = jump_velocity
	next_state = jump_state
