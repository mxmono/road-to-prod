extends StaticBody2D

# these are tuned so that the ball can go left, mid, or right on different force
var full_force: float = 600  # applied y linear velocity when fully pressed
var full_duration: float = 0.3  # time needed to fully press
var enabled: bool = true


func _input(event: InputEvent) -> void:
	
	if not enabled:
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_pressed("hold_spring"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:y", 738, full_duration).set_ease(Tween.EASE_OUT)
		tween.play()
		await tween.finished
		tween.kill()
	
	if Input.is_action_just_released("hold_spring"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:y", 688, full_duration).set_ease(Tween.EASE_OUT)
		tween.play()
		
		var progress = clampf((position.y - 688) / 50.0, 0, 1)
		var speed = full_force * progress
		self.constant_linear_velocity.y = -speed
		
		await tween.finished
		tween.kill()
		
		self.constant_linear_velocity.y = 0
