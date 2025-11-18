extends Node

@onready var player_one_node: CharacterBody2D = get_node("../Player1")
@onready var player_two_node: CharacterBody2D = get_node("../Player2")

func _ready() -> void:
  print(player_one_node)