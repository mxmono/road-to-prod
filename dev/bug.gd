class_name SkiBug extends Area2D

signal collected
@onready var sprite = $AnimatedSprite2D


func _ready() -> void:
	sprite.play("default")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is PlayerSki:
		set_deferred("monitoring", false)
		collected.emit(self)
		play_kill_animation()
		await get_tree().create_timer(1).timeout
		self.queue_free()


func play_kill_animation():
	sprite.play("die")
	var tween = get_tree().create_tween().set_parallel()
	
	var fly_offset = Vector2(randi_range(-200, 200), randi_range(100, 250))
	
	tween.tween_property(self, "position", self.position - fly_offset, 0.2)
	tween.tween_property(self, "rotation_degrees", 720, 0.2)
	tween.play()
