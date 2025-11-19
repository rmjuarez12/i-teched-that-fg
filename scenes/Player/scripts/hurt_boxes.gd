extends Node2D

@export var collision_shape: CollisionShape2D

func _draw():
    if collision_shape.shape is RectangleShape2D:
        var s = collision_shape.shape.size
        draw_rect(Rect2(-s/2, s), Color(1, 0, 0, 0.4), false)

    elif collision_shape.shape is CircleShape2D:
        draw_circle(Vector2.ZERO, collision_shape.shape.radius, Color(0, 1, 0, 0.4))