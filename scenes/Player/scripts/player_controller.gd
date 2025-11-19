extends CharacterBody2D

# Movement Vars
const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@export var is_facing_right: bool = true
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var state_machine: PlayerStateMachine = $StateMachine

# Define if player one
@export var is_player_one: bool = true
var opponent_node: CharacterBody2D
@onready var player_one_node: CharacterBody2D = get_node("../Player1")
@onready var player_two_node: CharacterBody2D = get_node("../Player2")

# Input vars
const p1Inputs: Dictionary = {
  "forward": "p1_forward",
  "back": "p1_back",
	"up": "p1_up",
	"down": "p1_down"
}

const p2Inputs: Dictionary = {
	"forward": "p2_forward",
  "back": "p2_back",
	"up": "p2_up",
	"down": "p2_down"
}

var player_inputs: Dictionary = {}

var motion_inputs: Dictionary = {
	"QCF": [2,3,6],
	"QCB": [2,1,4],
	"DP": [6,2,3],
	"HCF": [4, 1, 2, 3, 6],
	"FDash": [6, 6],
	"BDash": [4, 4]
}

# Input buffering
var input_buffer: Array = []
var buffer_timer:float = 0.5
var curr_directional_input:  Vector2 = Vector2(0, 0)
var prev_directional_input:  Vector2 = Vector2(0, 0)
@onready var buffering_timer = $InputBufferTimer

# For testing
@onready var input_type_label: Label = $Label 

func _ready() -> void:
	if is_player_one:
		player_inputs = p1Inputs
		opponent_node = player_two_node
	else:
		player_inputs = p2Inputs
		opponent_node = player_one_node

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# For basic movement
	handle_character_movement()
	handle_facing_direction()
	move_and_slide()

	# For basic input buffering
	handle_input_buffering()
	prune_buffer()

# Handles basic character movement
func handle_character_movement() -> void:
	var direction := Input.get_axis(player_inputs.back, player_inputs.forward)
	
	if direction and state_machine.current_state.can_move:
		velocity.x = direction * SPEED
	else:
		if state_machine.current_state.name == "Ground":
			velocity.x = move_toward(velocity.x, 0, SPEED)

# Changes character facing direction based on opponent's position
func handle_facing_direction() -> void:
	if position.x < opponent_node.position.x:
		is_facing_right = true
		sprite_2d.flip_h = false
	else:
		is_facing_right = false
		sprite_2d.flip_h = true

# Handles the input buffering for special moves
func handle_input_buffering() -> void:
	var left_right := Input.get_axis(player_inputs.back, player_inputs.forward)
	var up_down := Input.get_axis(player_inputs.down, player_inputs.up)

	# Set proper direction, taking in account where player is facing
	curr_directional_input = Vector2(left_right, up_down) if is_facing_right else Vector2(left_right * -1, up_down)

	# Convert to numpad notation
	var numpad_direction_convertion: int = 0

	if curr_directional_input == Vector2(-1,-1): numpad_direction_convertion = 1
	if curr_directional_input == Vector2(0,-1): numpad_direction_convertion = 2
	if curr_directional_input == Vector2(1,-1): numpad_direction_convertion = 3
	if curr_directional_input == Vector2(-1,0): numpad_direction_convertion = 4
	if curr_directional_input == Vector2(0,0): numpad_direction_convertion = 0
	if curr_directional_input == Vector2(1,0): numpad_direction_convertion = 6
	if curr_directional_input == Vector2(-1,1): numpad_direction_convertion = 7
	if curr_directional_input == Vector2(0,1): numpad_direction_convertion = 8
	if curr_directional_input == Vector2(1,1): numpad_direction_convertion = 9

	if prev_directional_input == curr_directional_input:
		return
	else: 
		prev_directional_input = curr_directional_input

		if numpad_direction_convertion != 0:
			input_buffer.append({ "dir": numpad_direction_convertion, "time": Time.get_ticks_msec() })

# Helper function to clean inputs from buffered list
func prune_buffer() -> void:
	var now = Time.get_ticks_msec()

	input_buffer = input_buffer.filter(func(entry):
		return now - entry.time < buffer_timer * 1000
	)

func match_motion(motion: Array) -> bool:
	var index = 0

	for entry in input_buffer:
		if entry.dir == motion[index]:
			index += 1

			if index >= motion.size():
				return true

	return false
