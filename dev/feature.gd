class_name SkiFeature extends Area2D

signal collected


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is PlayerSki:
		self.queue_free()
		collected.emit(self)
