extends Node2D

@onready var player_one_node: CharacterBody2D = get_node("../../Player1")
@onready var player_two_node: CharacterBody2D = get_node("../../Player2")

var font;

var player_1_last_directional_input: int = 0
var player_1_last_normal_input: String = ""
var player_1_history: Array[String] = []

var player_2_last_directional_input: int = 0
var player_2_last_normal_input: String = ""
var player_2_history: Array[String] = []

func _ready():
	font = ThemeDB.fallback_font

func _draw():
	var y = 20
	var y2 = 20

	var screen_size = get_viewport_rect().size

	for entry in player_1_history:
		draw_string(font, Vector2(20, y), str(entry))
		y += 20

	for entry in player_2_history:
		draw_string(font, Vector2(screen_size.x - 20, y2), str(entry))
		y2 += 20

func _process(_delta):

	var player_1_direction_input = player_one_node.get_directional_input()
	var player_2_direction_input = player_two_node.get_directional_input()

	var player_1_normal_input = player_one_node.get_normal_input()
	var player_2_normal_input = player_two_node.get_normal_input()

	add_to_history(player_1_direction_input, player_1_normal_input, true)
	add_to_history(player_2_direction_input, player_2_normal_input, false)

	queue_redraw()

func add_to_history(directional_input: int, normal_input: String, player_one: bool) -> void:

	var arrow_ref = define_arrow_string(directional_input)

	if player_one:
		if player_1_last_directional_input != directional_input:
			player_1_last_directional_input = directional_input

			if player_1_history.size() > 15:
				player_1_history.pop_front()
			
			if player_1_last_directional_input != 5:
				player_1_history.append(str(arrow_ref))
		
		if normal_input != player_1_last_normal_input:
			player_1_last_normal_input = normal_input

			if normal_input != "":
				player_1_history.append(normal_input)
	else:
		if player_2_last_directional_input != directional_input:
			player_2_last_directional_input = directional_input

			if player_2_history.size() > 15:
				player_2_history.pop_front()

			if player_2_last_directional_input != 5:
				player_2_history.append(str(arrow_ref))
		
		if normal_input != player_2_last_normal_input:
			player_2_last_normal_input = normal_input

			if normal_input != "":
				player_2_history.append(normal_input)

# Helper to choose what Icon to use
func define_arrow_string(direction: int):
	var string := ""

	if direction == 1: string = "↙"
	if direction == 2: string = "↓"
	if direction == 3: string = "↘"
	if direction == 4: string = "←"
	if direction == 6: string = "→"
	if direction == 7: string = "↖"
	if direction == 8: string = "↑"
	if direction == 9: string = "↗"

	return string