extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_parent = get_parent().get_parent()

var hitboxes: Array[Area2D]

func _ready() -> void:
	for child in get_parent().get_children():
		if child is Area2D:
			hitboxes.append(child)
		else: 
			push_error("Child node is not an Area2D: " + child.name)

func _process(_delta: float) -> void:
	if hitbox_parent.state_machine.current_state.name == "Attacking":
		toggle_hitboxes(true)
	else:
		toggle_hitboxes(false)

func toggle_hitboxes(enable: bool) -> void:
	for hitbox in hitboxes:
		var hitbox_display: ColorRect = hitbox.get_node("ColorRect")

		if enable:
			hitbox.monitoring = true
			hitbox.visible = true
			hitbox_display.visible = true
		else:
			hitbox.monitoring = false
			hitbox.visible = false
			hitbox_display.visible = false

func _on_area_entered(area: Area2D) -> void:
	var hurtbox_parent: CharacterBody2D = area.get_parent().get_parent()

	if hitbox_parent == hurtbox_parent:
		return

	if area.is_in_group("hurtboxes"):
		hurtbox_parent.velocity.x = 1000
		toggle_hitboxes(false)
	
