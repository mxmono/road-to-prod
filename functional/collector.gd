extends StaticBody2D

signal player_collected


func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is PlayerBall:
		await get_tree().create_timer(0.5).timeout
		player_collected.emit()
