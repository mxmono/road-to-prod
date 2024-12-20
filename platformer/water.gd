extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	

func _on_body_entered(body: Node2D):
	if body is Player:
		if not body.state == Player.PlayerState.CONTROL_DISABLED:
			body.state = Player.PlayerState.FLOATING


func _on_body_exited(body: Node2D):
	if body is Player:
		body.state = Player.PlayerState.NORMAL
