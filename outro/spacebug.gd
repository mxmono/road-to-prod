class_name SpaceBug extends Area2D

signal bug_defeated

enum Bugs {
	P2,
	P3,
	P4,
	USER_ERROR,
	BLOCKER,
	LOLCRY,
}

var anime_mapping: Dictionary = {
	Bugs.P2: "p2",
	Bugs.P3: "p3",
	Bugs.P4: "p4",
	Bugs.USER_ERROR: "usererror",
	Bugs.BLOCKER: "blocker",
	Bugs.LOLCRY: "lolcry",
}

var size_mapping: Dictionary = {
	Bugs.P2: 8,
	Bugs.P3: 4,
	Bugs.P4: 2,
	Bugs.USER_ERROR: 2,
	Bugs.BLOCKER: 2,  # this can be random between 1 and 4
	Bugs.LOLCRY: 6,
}

var bug = Bugs.P4
var speed
var time = 0
var num_hits_to_die: int = 1
var num_hits: int = 0

@onready var sprite = $AnimatedSprite2D
@onready var beam_particle = $CPUParticles2D
@onready var collision_shape = $CollisionShape2D
@onready var timer = $Timer  # self destroy 


func _ready() -> void:
	
	scale = Vector2(size_mapping[bug], size_mapping[bug])
	
	if bug == Bugs.LOLCRY:
		collision_shape.shape.size = Vector2(120, 120)
		speed = 100
		num_hits_to_die = 3
		timer.wait_time = 30
	else:
		collision_shape.shape.size = Vector2(60, 60)
		speed = randf_range(300, 700)
		num_hits_to_die = 1
		timer.wait_time = 10
	
	if bug == Bugs.BLOCKER:
		var rand_size = randi_range(1, 4)
		scale = Vector2(rand_size, rand_size)
	
	sprite.play(anime_mapping[bug])
	
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	

func _physics_process(delta: float) -> void:
	# move left
	position.x -=  speed * delta
	# up and down a little
	# amplitude * sin(time * frequency)
	# amplitude: y-axis range, frequency: how fast it oscillates, time: time accumulator
	time += delta
	position.y += 4 * sin(4 * time) + randf_range(-1, 1)
	

func _on_body_entered(body):
	if body is PlayerTire:
		
		num_hits += 1
		beam_particle.emitting = true
		var tween
		
		if num_hits >= num_hits_to_die:
			# play die animation and effects
			set_deferred("monitoring", false)
			
			# play die animation and effect
			sprite.play(anime_mapping[bug] + "_die")
			tween = get_tree().create_tween().set_parallel()
			tween.tween_property(self, "modulate:a", 0, 0.1)
			tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.1)
			tween.tween_property(self, "modulate:a", 0, 0.1).set_delay(0.2)
			tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.3)
			tween.tween_property(self, "scale", scale * 3, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.3)
			tween.tween_property(self, "position:x", self.position.x + 500, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			tween.play()
			
			bug_defeated.emit()
			await sprite.animation_finished
			await tween.finished
			queue_free()
	
		else:
			# bounce back
			tween = get_tree().create_tween().set_parallel()
			tween.tween_property(self, "modulate:a", 0, 0.1)
			tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.1)
			tween.tween_property(self, "modulate:a", 0, 0.1).set_delay(0.2)
			tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.3)
			tween.tween_property(self, "position:x", self.position.x + 500, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			tween.play()
			
			await tween.finished
			

func _on_timer_timeout():
	queue_free()
	bug_defeated.emit()
