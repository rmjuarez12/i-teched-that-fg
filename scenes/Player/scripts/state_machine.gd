extends Node

class_name PlayerStateMachine

@export var player_character: Node
@export var current_state : PlayerState
@export var animation_tree : AnimationTree

@export var forward_dash : PlayerState
@export var back_dash : PlayerState

var states : Array[PlayerState]

#For testing
@export var state_label: Label

func _ready() -> void:

  for child in get_children():
    if child is PlayerState:
      states.append(child)

      child.character = player_character
      child.playback = animation_tree["parameters/playback"]
    else: 
      push_error("Child node is not a PlayerState: " + child.name)

func _input(event : InputEvent):
  current_state.state_input(event)

func _physics_process(delta: float) -> void:

  if(current_state.next_state != null):
    switch_states(current_state.next_state)

  current_state.state_process(delta)
  state_label.set_text(current_state.name)

func switch_states(new_state : PlayerState):
  if(current_state != null):
    current_state.on_exit()
    current_state.next_state = null

  current_state = new_state

  current_state.on_enter()
