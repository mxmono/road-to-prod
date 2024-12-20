extends Node2D

signal pinball_started

@onready var player = $Player


func _ready() -> void:
	
	# ui setup
	player.state = Player.PlayerState.CONTROL_DISABLED
	$Banner.hide()
	$Teleport.hide()
	player.camera_enabled = false
	player.vertical_enabled = false
	$GUI/SubIntructions.hide()
	$GUI/ControlInstructions.hide()
	$GUI/ControlInstructions/Controls.hide()
	
	# remove any balls
	$Pinball.remove_ball()
	
	# connections
	$Teleport/Area2D.body_entered.connect(_on_teleporter_entered)
	$Pinball.playfield_entered.connect(_on_playfield_entered)
	$Pinball.won.connect(_on_player_win)
	$Pinball.stage_cleared.connect(_on_stage_cleared)
	
	# play cutscene
	play_intro()


func play_intro():
	
	# fade in
	Utils.fade_in_screen($GUI)
	await get_tree().create_timer(1).timeout
	
	player.set_animation("default")
	
	# robson walks in
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/IntroStop.position, 3)
	await tween.finished
	player.set_animation("still")
	
	# portal appears
	await get_tree().create_timer(1).timeout
	$Teleport.show()
	$Teleport/AnimatedSprite2D.play("open")
	await $Teleport/AnimatedSprite2D.animation_finished
	$Teleport/AnimatedSprite2D.play("default")
	$Teleport/Label.show()
	
	# enables robson
	player.state = Player.PlayerState.NORMAL


func _on_teleporter_entered(body):
	# descend robson to transmit to playfield
	if body is Player:
		player.state = Player.PlayerState.CONTROL_DISABLED
		player.set_animation("float")
		var tween = get_tree().create_tween()
		tween.tween_property(player, "global_position", $Markers/Teleporter.global_position, 1)
		await tween.finished
		await get_tree().create_timer(1).timeout
		
		player.queue_free()

		# close teleporter
		$Teleport/AnimatedSprite2D.play_backwards("open")
		await $Teleport/AnimatedSprite2D.animation_finished
		$Teleport.hide()
		
		# show play instructions and banner
		await get_tree().create_timer(1).timeout
		$GUI/SubIntructions.show()
		$GUI/ControlInstructions.show()
		$GUI/ControlInstructions/Controls.show()
		
		pinball_started.emit()


func _on_playfield_entered():
	$Banner.show()


func _on_player_win():
	# change animation
	$Banner/Robson.play("win")


func _on_stage_cleared():
	Utils.fade_out_screen($GUI)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://nfr/nfr.tscn")
