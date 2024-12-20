class_name CeleryWorker extends RigidBody2D

var power_level = 0
var max_power_level = 16


func _ready() -> void:
	$AnimatedSprite2D.play("default")
	self.power_level = 0
	$AnimatedSprite2D/Area2D.body_entered.connect(_on_body_entered)
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.wait_time = 10
	$Timer.start()


func _on_body_entered(body: Node) -> void:
	if body is CanonBall:
		body.queue_free()
		self.power_level += 1
		if self.power_level <= max_power_level:
			if self.power_level % (max_power_level / 2) == 0:
				powerup()


func powerup():
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate:a", 0, 0.1).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate:a", 1, 0.1).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property($AnimatedSprite2D, "scale", scale * (self.power_level / 10 + 1), 0.2).set_ease(Tween.EASE_OUT_IN)
	tween.play()
	
	$AnimatedSprite2D.play("hit")


func _on_timer_timeout():
	#die()
	pass


func set_animation(anime_name: String):
	$AnimatedSprite2D.play(anime_name)


func disable_collision():
	$AnimatedSprite2D/Area2D.set_deferred("monitorable", false)
	$AnimatedSprite2D/Area2D.set_deferred("monitoring", false)


func die():
	#print(self.power_level)
	disable_collision()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.1).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate:a", 1, 0.1).set_ease(Tween.EASE_OUT_IN)
	tween.set_loops(3)
	await tween.finished
	tween.kill()
	self.queue_free()
