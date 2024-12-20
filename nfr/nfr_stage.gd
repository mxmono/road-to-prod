class_name NFRStage extends Node2D

signal stage_cleared(stage)
signal stage_failed(stage)

var enabled: bool = true
var num_letters: int = 3
enum Stage {
	IDLE,
	TYPING,
}
var letters = [KEY_A, KEY_S, KEY_D]
var current_stage = Stage.IDLE
var letters_normal: Dictionary = {
	KEY_W: preload("res://texture/key_w.png"),
	KEY_A: preload("res://texture/key_a.png"),
	KEY_S: preload("res://texture/key_s.png"),
	KEY_D: preload("res://texture/key_d.png"),
	KEY_ASTERISK: preload("res://texture/key_question.png"),  # placeholder for unknown letter
}
var letters_pressed: Dictionary = {
	KEY_W: preload("res://texture/key_w2.png"),
	KEY_A: preload("res://texture/key_a2.png"),
	KEY_S: preload("res://texture/key_s2.png"),
	KEY_D: preload("res://texture/key_d2.png"),
	KEY_ASTERISK: preload("res://texture/key_question.png"),
}
var letters_disabled: Dictionary = {
	KEY_W: preload("res://texture/key_w3.png"),
	KEY_A: preload("res://texture/key_a3.png"),
	KEY_S: preload("res://texture/key_s3.png"),
	KEY_D: preload("res://texture/key_d3.png"),
	KEY_ASTERISK: preload("res://texture/key_question3.png"),
}
var letter_sequence: PackedInt32Array = []
var letter_index: int = 0
var add_question: bool = false  # for the last stage trick, impossible to finish

@onready var stopwatch = $StopWatch


func _ready() -> void:
	
	# clean UI
	for button in $LetterZone/Container/VBoxContainer.get_children():
		button.queue_free()
	stopwatch.text = "0.00s"
	letter_sequence = []
	$Hint.global_position.y = $LetterZone.global_position.y
	$Hint.hide()
	
	# lane open or not
	if enabled:
		enable()
	else:
		disable()
	
	# connect signals
	$Start.body_entered.connect(_on_body_entered)


func _input(event):
	if not self.current_stage == Stage.TYPING:
		return
	
	if event is InputEventKey and event.pressed:
		
		if Input.is_key_pressed(self.letter_sequence[self.letter_index]):
			
			var button: TextureButton = $LetterZone/Container/VBoxContainer.get_children()[self.letter_index]
			button.texture_normal = letters_pressed[self.letter_sequence[self.letter_index]]
			self.letter_index += 1
			
			# if next letter is the trick question, only show it when the prev one is cleared
			# this is failsafe, ideally users can't type fast enough, but if they can, block them
			if self.letter_index < self.letter_sequence.size():
				if self.letter_sequence[self.letter_index] == KEY_ASTERISK:
					if stopwatch.timer <= 1:
						$LetterZone/Container/VBoxContainer.get_child(letter_index).show()
						# if player already failed, skip the last letter
					else:
						letter_index += 1
			
			# if the last letter is correct
			if self.letter_index == self.num_letters:
				self.current_stage = Stage.IDLE
				stopwatch.stop()
				
				if stopwatch.timer <= 1:
					stage_cleared.emit(self)
					$Hint.hide()
				else:
					stage_failed.emit(self)
					$Hint.hide()
		
		# if not, fail the stage, to prevent player just hitting all keys all the time
		else:
			var button: TextureButton = $LetterZone/Container/VBoxContainer.get_children()[self.letter_index]
			button.texture_normal = letters_disabled[self.letter_sequence[self.letter_index]]
			self.current_stage = Stage.IDLE
			stopwatch.stop()
			stage_failed.emit(self)
			$Hint.hide()


func _on_body_entered(body):
	if body is Player:
		
		body.state = Player.PlayerState.CONTROL_DISABLED
		
		# reset states in case playing twice+
		reset_stage()
		
		await get_tree().create_timer(1).timeout
		spawn_letters()


func reset_stage():
	for button in $LetterZone/Container/VBoxContainer.get_children():
		button.queue_free()
	stopwatch.reset()
	letter_sequence = []
	letter_index = 0
	
	$Hint.visible = true
	$Hint/StartTyping.text = "GET READY"
	$Hint.global_position.y = $LetterZone.global_position.y
	
	$LetterZone/ProgressLine.size.y = 0


func enable():
	$Start/Sprite.texture = preload("res://texture/open.png")
	$Block/CollisionShape2D.disabled = true
	$LetterZone.color = Color("a8b05a")
	$StopWatch.visible = true


func disable():
	$Start/Sprite.texture = preload("res://texture/locked.png")
	$Block/CollisionShape2D.disabled = false
	$LetterZone.color = Color("a73547")
	$StopWatch.visible = false
	

func spawn_letters():
	# pick letters
	for i in range(num_letters):
		randomize()
		self.letter_sequence.append(letters.pick_random())
	if self.add_question:
		self.letter_sequence.append(KEY_ASTERISK)
		self.num_letters += 1
	
	# line up the letter icons
	for letter in self.letter_sequence:
		var button = TextureButton.new()
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
		button.custom_minimum_size = Vector2(64, 64)
		button.texture_normal = letters_normal[letter]
		$LetterZone/Container/VBoxContainer.add_child(button)
		
		# hide it first
		if letter == KEY_ASTERISK:
			button.hide()

	# start typing
	progress_to_start()


func progress_to_start():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($LetterZone/ProgressLine, "size:y", $LetterZone.size.y, 2).set_ease(Tween.EASE_IN)
	tween.tween_property($Hint, "global_position:y", $LetterZone.global_position.y + $LetterZone.size.y, 2).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property($LetterZone/ProgressLine, "modulate", Color(1, 1, 1, 0), 0.1)
	tween.tween_property($LetterZone/ProgressLine, "modulate", Color(1, 1, 1, 1), 0.1)
	$Hint/StartTyping.text = "START"
	
	stopwatch.start()
	
	self.current_stage = Stage.TYPING


func reset_timer():
	stopwatch.reset()
