extends Node2D

@export var speed: float = 5.0
@export var start_position = Vector2(736.0, 64.0)
var screen_width = 720


func _ready() -> void:
	screen_width = get_viewport().size.x


func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -500.0:
		position.x = screen_width + 300
