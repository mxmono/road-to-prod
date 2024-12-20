extends Area2D


signal leeks_squashed()

var received_celeries: int = 0
var received_list: Array = []
var plank_down_step: int = 0
var plank_total_steps: int = 6


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is CeleryWorker:
		if received_list.has(body):
			return
		body.disable_collision()
		
		if body.power_level < body.max_power_level:
			body.call_deferred("die")
		
		else:
			received_celeries += 1
			received_list.append(body)
		
			if received_celeries % 1 == 0:
				plank_down_step += 1
				print(plank_down_step)
				update_plank()


func update_plank():
	
	# lower the plank
	var current_position = global_position
	var tween = get_tree().create_tween()
	var offset = Vector2(0, 27)  # tiles = 18, scale = 1.5
	var overshoot = Vector2(0, 3)
	tween.tween_property(self, "global_position", current_position + offset + overshoot, 0.2).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "global_position", current_position + offset, 0.1).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property($"../Leeks", "scale", Vector2(1, 1 - float(plank_down_step) / plank_total_steps), 0.2)
	tween.play()
	
	if plank_down_step >= plank_total_steps:
		leeks_squashed.emit()
