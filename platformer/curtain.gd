extends Area2D

@onready var main_scene = $"../.."


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if body is Player:
		
		$"../../GUI/Status".visible = false
		
		body.state = Player.PlayerState.CONTROL_DISABLED
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0, 1)
		tween.play()
		
		await tween.finished
	
		main_scene.animate_label_change($"../../GUI/Instructions", "HAVE A SOAK!")
		
		await get_tree().create_timer(2).timeout
		
		main_scene.play_soak_animation()
		$CollisionShape2D.disabled = true
