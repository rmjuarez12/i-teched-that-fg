extends CharacterBody2D

# Helper function to match motion inputs
func match_motion(motion: Array) -> bool:
	var index := 0

	for entry in input_buffer:
		if entry.dir == motion[index]:
			index += 1

			if index >= motion.size():
				return true

	return false

# ==========================================
# General Character Config
# ==========================================

# Define the character
@export_enum("Brickhouse Bruno", "Nyaa-Chains", "Leah") var character_name: String

# Movement Vars
var speed = 100.0
var jump_height = -400.0

# Character Specific Config
var character_config: Dictionary = {
	"bruno": {
		"speed": 100,
		"jump_height": -400,
		"jump_speed": 200
	},
	"nya": {
		"speed": 150,
		"jump_height": -450,
		"jump_speed": 250
	}
}

# Helper variables for character behavior
var is_facing_right: bool = true

var opponent_node: CharacterBody2D
@onready var player_one_node: CharacterBody2D = get_node("../Player1")
@onready var player_two_node: CharacterBody2D = get_node("../Player2")

# ==========================================
# Define Important Resources
# ==========================================

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine

# Define animation tree. Will be added later, depending of character specified.
var animation_tree : AnimationTree

# ==========================================
# General Input Configurations
# ==========================================

# Using the inputs from Godot's project settings
const defined_inputs: Dictionary = {
	"player_one": {
		"forward": "p1_forward",
		"back": "p1_back",
		"up": "p1_up",
		"down": "p1_down",
		"l": "p1_L",
		"m": "p1_M"
	}, 
	"player_two": {
		"forward": "p2_forward",
		"back": "p2_back",
		"up": "p2_up",
		"down": "p2_down",
		"l": "p2_L",
		"m": "p2_M"
	}
}

# Helper variable use to insert the inputs based on player
var player_inputs: Dictionary = {}

# Set of motion input combinations to be used for special motion inputs
var motion_inputs: Dictionary = {

	# Quarter Circle
	"QCF": "236",
	"QCB": "214",

	# DP
	"DP": "623",

	# Half Circle
	"HCF": "41236",
	"HCB": "63214",

	# Double inputs
	"FDash": "66",
	"BDash": "44",
	"DownDown": "22",

	# Monstrosity
	"Pretzel": "1632143",
	"ReversePretzel": "3412361",
	"Konami": "88224646",
}

# ==========================================
# Input Bufferin Configurations
# ==========================================

# Input buffering config
var input_buffer: Array = []

@export var buffer_max_length: int = 20
@export var input_timeout: float = 0.4

var prev_directional_input:  int = 0
var input_timer: Timer

# ==========================================
# Ready and Process functions
# ==========================================

func _ready() -> void:

	# Declare the proper inputs to the proper player
	if name == "Player1":
		player_inputs = defined_inputs.player_one
		opponent_node = player_two_node
	else:
		player_inputs = defined_inputs.player_two
		opponent_node = player_one_node

	# Define what animation tree to load, based on character
	if character_name == "Brickhouse Bruno":
		animation_tree = $"BigGuyResources/BGAnimationTree"
		speed = 50

	animation_tree.active = true

	# Create a timer to be used for input buffering
	input_timer = Timer.new()
	input_timer.wait_time = input_timeout
	input_timer.timeout.connect(_on_input_timeout)
	add_child(input_timer)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# For basic movement
	handle_character_movement()
	handle_facing_direction()
	move_and_slide()

	# Input buffering
	handle_buffer_input()
	_check_motions()

# ==========================================
# Input Buffering Handlers
# ==========================================

func handle_buffer_input():
	var curr_directional_input = get_directional_input()

	if curr_directional_input != prev_directional_input:
			input_buffer.append(curr_directional_input)
			prev_directional_input = curr_directional_input
			input_timer.start()  # Restart timeout
	
	if input_buffer.size() > buffer_max_length:
			input_buffer = input_buffer.slice(-buffer_max_length)

func get_recent_buffer(max_chars: int = 20) -> String:
	var recent = input_buffer.slice(max(0, input_buffer.size() - max_chars * 2))
	var s = ""
	for dir in recent:
		if dir != 5:
			s += str(dir)
	return s.to_upper() 

func is_subsequence(pattern: String, text: String) -> bool:
	var p = 0

	print(pattern)
	print(text)
	for c in text:
			if p < pattern.length() and c == pattern[p]:
				p += 1
	return p == pattern.length()

func _check_motions():
	var buf = get_recent_buffer(5)
	
	if buf.find(motion_inputs["FDash"]) != -1:
		if is_on_floor():
			print("FDASH")
			state_machine.current_state.next_state = state_machine.forward_dash

		input_buffer.clear()  # Consume
		return

func dispatch_action():
	var recent_20 = get_recent_buffer(20)
	
	# PRIORITY: Supers first!
	if is_subsequence(motion_inputs["Pretzel"], recent_20):
		print("Grab L 1")
		input_buffer.clear()
		return "l_attack_1"
	elif is_subsequence(motion_inputs["Konami"], recent_20):
		print("Grab L 2")
		input_buffer.clear()
		return "l_attack_2"
	else:
		print("normal")
		return "normal"

func _on_input_timeout():
	input_buffer.clear()

# ==========================================
# General Character Behavior
# ==========================================

# Handles basic character movement
func handle_character_movement() -> void:
	var direction := Input.get_axis(player_inputs.back, player_inputs.forward)

	animation_tree.set("parameters/Move/blend_position", direction)
	
	if direction and state_machine.current_state.can_move:
		velocity.x = direction * speed
	else:
		if state_machine.current_state.name == "Ground":
			velocity.x = move_toward(velocity.x, 0, speed)

# Changes character facing direction based on opponent's position
func handle_facing_direction() -> void:

	if position.x < opponent_node.position.x:
		is_facing_right = true
		sprite_2d.flip_h = false
	else:
		is_facing_right = false
		sprite_2d.flip_h = true

# ==========================================
# Helper functions to get directional input(numpad notation) and normals
# ==========================================

func get_directional_input() -> int:
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
	if directional_input == Vector2(0,0): numpad_direction_convertion = 5
	if directional_input == Vector2(1,0): numpad_direction_convertion = 6
	if directional_input == Vector2(-1,1): numpad_direction_convertion = 7
	if directional_input == Vector2(0,1): numpad_direction_convertion = 8
	if directional_input == Vector2(1,1): numpad_direction_convertion = 9

	return numpad_direction_convertion

func get_normal_input() -> String:
	var input_str := ""

	if Input.is_action_pressed(player_inputs.l): input_str = "A"
	if Input.is_action_pressed(player_inputs.m): input_str = "B"

	return input_str

# ==========================================
# General Character Behavior
# ==========================================
