class_name PinballTarget extends Area2D

signal target_lit()

@export var lit = false

var unlit_sprite = preload("res://texture/gray-ball.png")
var lit_sprite = preload("res://texture/yellow-ball.png")


func _ready() -> void:
	$Sprite2D.texture = unlit_sprite
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is PlayerBall:
		if not lit:
			lit = true
			target_lit.emit()
			$Sprite2D.texture = lit_sprite
