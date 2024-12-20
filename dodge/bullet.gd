extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is Player:
		body.die()


func shoot(end_position: Vector2, duration: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", end_position, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
