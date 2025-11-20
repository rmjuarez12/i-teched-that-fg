extends PlayerState

@export var ground_state: PlayerState

var attack_type: String
var attack: bool = false

var frames_counter: float
var startup_frames: float
var active_frames: float

var frame_time := 1.0 / 60.0
var accumulator := 0.0

var start_up_end: bool

func on_enter() -> void:
	frames_counter = 0

	if attack_type == "l_attack_1":
		bg_light_grab()

	if attack_type == "l_attack_2":
		bg_light_grab()

func state_process(_delta):
	accumulator += _delta

	while accumulator >= frame_time:
		accumulator -= frame_time
		frames_counter += 1
	
	if attack_type == "l_attack_1":
		if frames_counter == startup_frames and not start_up_end:
			start_up_end = true
			frames_counter = 0
			attack = true
			character.velocity.x = 500 if character.is_facing_right else -500
			character.velocity.y = -150
			character.velocity.y += -1700 * _delta

		if frames_counter == active_frames and start_up_end:
			start_up_end = false
			frames_counter = 0
			next_state = ground_state
	
	if attack_type == "l_attack_2":
		if frames_counter == startup_frames and not start_up_end:
			start_up_end = true
			frames_counter = 0
			attack = true
			character.velocity.x = 500 if character.is_facing_right else -500
			character.velocity.y = -450
			character.velocity.y += -1700 * _delta

		if frames_counter == active_frames and start_up_end:
			start_up_end = false
			frames_counter = 0
			next_state = ground_state
			character.velocity = Vector2.ZERO
	

# Big guy moveset
func bg_light_grab():
	playback.travel("grab_startup")
	character.velocity.x = 0