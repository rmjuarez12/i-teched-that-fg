extends CharacterBody2D

# Movement Vars
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var is_facing_right: bool = true
@onready var sprite_2d: Sprite2D = $Sprite2D

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

func _ready() -> void:
	if is_player_one:
		player_inputs = p1Inputs
		opponent_node = player_two_node
	else:
		player_inputs = p2Inputs
		opponent_node = player_one_node

	print("For the node " + name)
	print(opponent_node)
	print("===")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(player_inputs.up) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	handle_character_movement()
	# handle_facing_direction()

	move_and_slide()

func handle_character_movement() -> void:
	var direction := Input.get_axis(player_inputs.back, player_inputs.forward)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_facing_direction() -> void:
	if position.x < opponent_node.position.x:
		is_facing_right = true
		sprite_2d.flip_h = false
	else:
		is_facing_right = false
		sprite_2d.flip_h = true
