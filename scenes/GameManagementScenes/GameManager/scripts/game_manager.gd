extends Node

@onready var player_one_node: CharacterBody2D = get_node("../Player1")
@onready var player_two_node: CharacterBody2D = get_node("../Player2")

@onready var input_history_canvas: Node2D = $InputHistory

var font;

func _ready():
  font = ThemeDB.fallback_font

func _draw():
  var y = 20

  for entry in player_one_node.input_buffer:
    print(entry)
    input_history_canvas.draw_string(font, Vector2(20, y), str(entry.dir))
    y += 20

func _process(_delta):
  input_history_canvas.queue_redraw()
