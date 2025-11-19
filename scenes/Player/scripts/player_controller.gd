extends CharacterBody2D

# Define the character
@export_enum("Brickhouse Bruno", "Nyaa-Chains", "Leah") var character_name: String

# Movement Vars
var SPEED = 100.0
var JUMP_VELOCITY = -400.0

@export var is_facing_right: bool = true
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var state_machine: PlayerStateMachine = $StateMachine

@export var player_hitboxes: Node2D
@export var player_hurtboxes: Node2D

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
	"down": "p1_down",
	"l": "p1_L"
}

const p2Inputs: Dictionary = {
	"forward": "p2_forward",
  "back": "p2_back",
	"up": "p2_up",
	"down": "p2_down",
	"l": "p2_L"
}

var player_inputs: Dictionary = {}

var motion_inputs: Dictionary = {

	# Quarter Circle
	"QCF": [2,3,6],
	"QCB": [2,1,4],

	# DP
	"DP": [6,2,3],

	# Half Circle
	"HCF": [4, 1, 2, 3, 6],
	"HCB": [6, 3, 2, 1, 4],

	# Double inputs
	"FDash": [6, 6],
	"BDash": [4, 4],
	"DownDown": [2, 2],

	# Monstrosity
	"Pretzel": [1, 6, 3, 2, 1, 4, 3],

	# Charge
	"CHARGE_BF": { "charge":4, "release":6, "time":0.6 },
	"CHARGE_DU": { "charge":2, "release":8, "time":0.5 }
}

var hold_times := {
    1:0,2:0,3:0,
    4:0,5:0,6:0,
    7:0,8:0,9:0
}

var last_dir := 5

# Input buffering
var input_buffer: Array = []
var buffer_timer:float = 0.5
var curr_directional_input:  int = 0
var prev_directional_input:  int = 0
@onready var buffering_timer = $InputBufferTimer

# Define animation tree
var animation_tree : AnimationTree

# For testing
@onready var input_type_label: Label = $Label 

func _ready() -> void:
	if is_player_one:
		player_inputs = p1Inputs
		opponent_node = player_two_node
	else:
		player_inputs = p2Inputs
		opponent_node = player_one_node
	
	var char_animation_tree: AnimationTree

	if character_name == "Brickhouse Bruno":
		char_animation_tree = $"BigGuyAnim/BGAnimationTree"
		SPEED = 50

	animation_tree = char_animation_tree
	animation_tree.active = true

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

	animation_tree.set("parameters/Move/blend_position", direction)
	
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
	var directional_input = get_directional_input()

	curr_directional_input = directional_input

	if prev_directional_input == curr_directional_input:
		return
	else: 
		prev_directional_input = curr_directional_input

		if directional_input != 0:
			input_buffer.append({ "dir": directional_input, "time": Time.get_ticks_msec() })

# Helper function to get current directional input
func get_directional_input():
	var left_right := Input.get_axis(player_inputs.back, player_inputs.forward)
	var up_down := Input.get_axis(player_inputs.down, player_inputs.up)

	# Set proper direction, taking in account where player is facing
	var directional_input = Vector2(left_right, up_down) if is_facing_right else Vector2(left_right * -1, up_down)

	# Convert to numpad notation
	var numpad_direction_convertion: int = 0

	if directional_input == Vector2(-1,-1): numpad_direction_convertion = 1
	if directional_input == Vector2(0,-1): numpad_direction_convertion = 2
	if directional_input == Vector2(1,-1): numpad_direction_convertion = 3
	if directional_input == Vector2(-1,0): numpad_direction_convertion = 4
	if directional_input == Vector2(0,0): numpad_direction_convertion = 0
	if directional_input == Vector2(1,0): numpad_direction_convertion = 6
	if directional_input == Vector2(-1,1): numpad_direction_convertion = 7
	if directional_input == Vector2(0,1): numpad_direction_convertion = 8
	if directional_input == Vector2(1,1): numpad_direction_convertion = 9

	return numpad_direction_convertion

# Helper function to get current directional input
func get_normal_input():
	var input_str := ""

	if Input.is_action_just_pressed(player_inputs.l): input_str = "L"

	return input_str

# Helper function to clean inputs from buffered list
func prune_buffer() -> void:
	var now = Time.get_ticks_msec()

	input_buffer = input_buffer.filter(func(entry):
		return now - entry.time < buffer_timer * 1000
	)

# Helper function to match motion inputs
func match_motion(motion: Array) -> bool:
	var index := 0

	for entry in input_buffer:
		if entry.dir == motion[index]:
			index += 1

			if index >= motion.size():
				return true

	return false

# func update_hold_times(delta):
# 	var dir = get_direction()

# 	if dir == last_dir:
# 			hold_times[dir] += delta
# 	else:
# 			hold_times[dir] = 0
# 			last_dir = dir

# Helper function to match charged inputs
func match_charge(motion_name: String) -> bool:
	var m = motion_inputs[motion_name]

	if hold_times[m.charge] < m.time:
		return false

	return match_motion([m.release])

# Helper function that helps with matching double inputs, such
# as dashes and down down
func match_double_input() -> bool:
	var last_time = null
	var threshold := 120 

	for entry in input_buffer:
		if entry.dir == 6 or entry.dir == 4:
			if last_time == null:
				last_time = entry.time
			else:
				if entry.time - last_time <= threshold:
					return true
				last_time = entry.time

	return false

func dispatch_actions():

	# -------- SUPER PRIORITY --------
	if match_motion(motion_inputs["Pretzel"]):
		return "Pretzel"

	# -------- SPECIAL PRIORITY --------
	if match_motion(motion_inputs["DP"]):
			return "DP"

	if match_motion(motion_inputs["QCF"]):
			return "QCF"

	if match_charge("CHARGE_BF"):
			return "SONIC_BOOM"

	# -------- DASH (lower priority) --------
	if match_double_input():
			return "DASH"

	return ""