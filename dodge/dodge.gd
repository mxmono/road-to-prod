extends Node2D

signal dialog_line_finished

@onready var player: Player = $Player
@onready var stakeholder = $Stakeholder
@onready var dialog = $GUI/Dialog
@onready var bullet = $Bullet

@export var stage: int = 1
var total_stages: int = 3
var in_dialog: bool = false

enum Choice {
	W,
	S,
	D,
	O,
}

@onready var destination_mapping: Dictionary = {
	Choice.W: $Markers/W.global_position,
	Choice.S: $Markers/S.global_position,
	Choice.D: $Markers/D.global_position,
	Choice.O: $Markers/Start.global_position,
}


func _ready() -> void:
	
	# set robson
	player.vertical_enabled = false
	player.camera_enabled = false
	player.state = Player.PlayerState.CONTROL_DISABLED
	player.global_position = $Markers/Intro.global_position
	
	# set stakeholder
	stakeholder.set_animation("default")
	stakeholder.global_position = $Markers/Animation/StakeholderIn1.global_position
	$Bullet.visible = false
	
	# set labels
	$GUI/Countdown.visible = false
	$GUI/Countdown.text = ""
	$GUI/StakeholderAppeared.modulate.a = 0
	dialog.hide()
	
	# disable buttons
	for button: TextureButton in $DodgeButtons.get_children():
		button.hide()
	
	# play intro
	await play_intro()
	
	# play scene
	play_scene()


func _input(_event: InputEvent) -> void:
	if in_dialog:
		if not dialog.dialog_typing:
			if Input.is_action_just_pressed("continue"):
				dialog_line_finished.emit()


func play_intro():
	
	Utils.fade_in_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(1).timeout
	
	# robson walks in
	player.set_animation("default")
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/Start.global_position, 2)
	
	await tween.finished
	tween.kill()
	
	# stakeholder appears and floats around
	stakeholder.set_animation("default")
	stakeholder.global_position = $Markers/Animation/StakeholderIn1.global_position
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(stakeholder, "modulate:a", 0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stakeholder, "global_position", $Markers/Animation/StakeholderOut1.global_position, 1).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	
	await tween.finished
	player.set_animation("scared")
	tween.kill()
	
	tween = get_tree().create_tween().set_parallel()
	stakeholder.global_position = $Markers/Animation/StakeholderIn2.global_position
	stakeholder.modulate.a = 1
	tween.tween_property(stakeholder, "modulate:a", 0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stakeholder, "global_position", $Markers/Animation/StakeholderOut2.global_position, 1).set_trans(Tween.TRANS_CUBIC)
	tween.play()

	await tween.finished
	tween.kill()
	
	# stakeholder goes into position
	stakeholder.set_animation("stake")
	tween = get_tree().create_tween().set_parallel()
	stakeholder.global_position = $Markers/Animation/StakeholderIn3.global_position
	tween.tween_property(stakeholder, "modulate:a", 1, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stakeholder, "global_position", $Markers/Animation/StakeholderOut3.global_position, 1).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	
	await tween.finished
	tween.kill()
	
	# flash the label
	tween = get_tree().create_tween().set_loops(3)
	var label = $GUI/StakeholderAppeared
	tween.tween_property(label, "modulate:a", 1, 0.2)
	tween.tween_property(label, "modulate:a", 0, 0.2)
	tween.play()
	
	await tween.finished
	tween.kill()


func play_scene():
	
	while self.stage <= self.total_stages:
		
		# go to starting position and play starting animations
		reset_positions()
		Utils.flash_screen($ColorRect)
		
		# enable buttons for next stage
		match self.stage:
			1:
				$DodgeButtons.enable_and_show_button(Choice.W)
				$DodgeButtons.enable_and_show_button(Choice.D)
				$DodgeButtons.enable_and_show_button(Choice.S)
			2:
				$DodgeButtons.enable_and_show_button(Choice.W)
				$DodgeButtons.disable_and_hide_button(Choice.D)
				$DodgeButtons.enable_and_show_button(Choice.S)
			3:
				$DodgeButtons.disable_and_hide_button(Choice.W)
				$DodgeButtons.enable_and_show_button(Choice.D)
				$DodgeButtons.disable_and_hide_button(Choice.S)
		
		# random interval
		await get_tree().create_timer(randf_range(2, 5)).timeout
		
		# count down and shoot
		var is_stage_cleared = await shoot()
		
		await get_tree().create_timer(1).timeout
		if is_stage_cleared:
			self.stage += 1
			
			if self.stage <= total_stages:
				player.set_label("DODGED!", Vector2(1, 1), Color(1, 1, 1))
				player.set_animation("float")
			
			else:
				# final scene
				play_final_scene()
				
				break
				
			await get_tree().create_timer(2).timeout
			player.set_label("NEXT ROUND!", Vector2(1, 1), Color(1, 1, 1))
		else:
			player.set_label("TRY AGAIN!", Vector2(1, 1), Color(1, 1, 1))
		
		await get_tree().create_timer(2).timeout
		player.hide_label()
		
		print(self.stage)


func shoot() -> bool:
	"""Returns true if dodged successfully, otherwise returns false."""
	
	# count down
	$GUI/Countdown.visible = true
	for i in range(4):
		await stakeholder.animated_sprite.animation_looped
		$GUI/Countdown.text = str(3 - i)
	
	$GUI/Countdown.visible = false
	$GUI/Countdown.text = ""
	
	# disable buttons
	$DodgeButtons.disable_all()
	
	# robson dodges
	var dodge_destination: Vector2
	var player_choice: int
	
	if $DodgeButtons/W.button_pressed:
		player_choice = Choice.W
	elif $DodgeButtons/S.button_pressed:
		player_choice = Choice.S
	elif $DodgeButtons/D.button_pressed:
		player_choice = Choice.D
	else:
		player_choice = Choice.O
		
	dodge_destination = destination_mapping[player_choice]
	
	# if hide behind a button, play hide animation
	if player_choice != Choice.O:
		player.set_animation("hide")
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", dodge_destination, 0.2).set_ease(Tween.EASE_OUT_IN)
	
	
	# determine shoot position
	var destination: Vector2
	var shoot_choice: int
	if player_choice == Choice.O:
		shoot_choice = Choice.O
	else:
		var markers = []
		match self.stage:
			1: markers = [Choice.W, Choice.S, Choice.D]
			2: markers = [Choice.W, Choice.S]
			3: markers = [Choice.D]
		markers.shuffle()
		shoot_choice = markers[0]
	
	destination = destination_mapping[shoot_choice]
	
	print("player choice: %s, shoot choice: %s" % [player_choice, shoot_choice])

	# shoot to destination
	stakeholder.set_animation("shoot")
	
	# final stage, turn off bullet collision (so player doesn't die)
	if stage == total_stages:
		if player_choice != Choice.O:
			$Bullet.monitoring = false
	
	await get_tree().create_timer(1 / 5.0 * 4).timeout  # 5 fps
	$Bullet.visible = true
	$Bullet.shoot(destination, 0.5)
	Utils.flash_screen($ColorRect)
	
	# final stage, robson bites the bullet and returns true
	if stage == total_stages:
		if player_choice != Choice.O:
			player.set_animation("bite")
			return true
	
	# return
	if player_choice != shoot_choice:
		return true
	
	return false


func reset_positions():
	player.global_position = $Markers/Start.global_position
	player.set_animation("scared")

	stakeholder.set_animation("stake")
	
	$Bullet.global_position = $Markers/Gun.global_position
	$Bullet.visible = false
	
	$DodgeButtons.reset_all()

	$GUI/Stats.set_text("ROUND %s" % str(self.stage))
	Utils.flash_label($GUI/Stats, 3)


func play_final_scene():
	# final scene
	Utils.flash_screen($ColorRect)
	player.set_label("IMPOSSIBLE TO DODGE!")
	await get_tree().create_timer(2).timeout
	Utils.flash_screen($ColorRect)
	player.set_label("YOU BIT THE BULLET!", Vector2(0.8, 0.8))
	await zoom_camera(Vector2(2, 2), Vector2(150, 200))
	
	$DodgeButtons/D.visible = false
	
	await get_tree().create_timer(4).timeout 
	
	# robson uhs and bullet shoots off
	player.set_animation("uh")
	bullet.hide()
	await get_tree().create_timer(2).timeout
	player.hide_label()
	
	# zoom camera back out
	stakeholder.animated_sprite.play("default")
	await zoom_camera(Vector2(1, 1), Vector2(0, 0))
	
	# start dialog
	await get_tree().create_timer(1).timeout
	in_dialog = true
	dialog.show()
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "HEHEHE, NOT BAD!")
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "I'LL GIVE YOU ONE LAST TEST! LET'S SEE HOW YOU DO!")
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "HEHEHEHEHE!")
	await dialog_line_finished
	in_dialog = false
	
	await Utils.fade_out_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://platformer/soak.tscn")


func zoom_camera(zoom_scale: Vector2 = Vector2(2, 2), camera_offset: Vector2 = Vector2(150, 200)):
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Camera2D, "zoom", zoom_scale, 1).set_ease(Tween.EASE_IN)
	tween.tween_property($Camera2D, "offset", camera_offset, 1).set_ease(Tween.EASE_IN)
	tween.play()
