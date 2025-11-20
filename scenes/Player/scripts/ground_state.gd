extends PlayerState

@export var jump_speed:float = -400.0

@export var jump_state: PlayerState
@export var crouch_state: PlayerState
@export var attack_state: PlayerState
@export var falling_state: PlayerState
@export var f_dash_state: PlayerState
@export var b_dash_state: PlayerState

var is_crouched:bool = false

func state_process(_delta):
	if not character.is_on_floor():
		next_state = falling_state
	
	if is_crouched:
		playback.travel("crouch")
		can_move = false
	else:
		playback.travel("Move")
		can_move = true

func state_input(event : InputEvent):
	if(event.is_action_pressed(character.player_inputs.up) and can_move):
		jump(event)

	if event.is_action_pressed(character.player_inputs.down):
		is_crouched = true
	
	if event.is_action_released(character.player_inputs.down):
		is_crouched = false

	var action = character.dispatch_actions()

	print(action)

	if action == "QCF" and Input.is_action_just_pressed(character.player_inputs.l):
		next_state = attack_state
		next_state.attack_type = "l_attack_1"
		next_state.startup_frames = 10
		next_state.active_frames = 25
	
	if action == "QCB" and Input.is_action_just_pressed(character.player_inputs.l):
		next_state = attack_state
		next_state.attack_type = "l_attack_2"
		next_state.startup_frames = 10
		next_state.active_frames = 25
	# elif character.match_motion(character.motion_inputs["FDash"]):
	# 	next_state = f_dash_state
	# elif character.match_motion(character.motion_inputs["BDash"]):
	# 	next_state = b_dash_state

func jump(_event : InputEvent):
	var jump_velocity = jump_speed

	character.velocity.y = jump_velocity
	next_state = jump_state
