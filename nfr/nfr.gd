extends Node2D

var cleared_stages: Array[NFRStage]
var num_letters = [3, 4, 5, 8]
var failure_count: Dictionary

@onready var player: Player = $Player


func _ready() -> void:
	player.camera_enabled = false
	player.vertical_enabled = true
	player.global_position = $Markers/PlayerStart.global_position
	player.state = Player.PlayerState.CONTROL_DISABLED
	
	$GUI/ClearLabel.hide()
	
	for node in $Stages.get_children():
		node.free()
	
	for i in range(4):
		var stage_scene = preload("res://nfr/nfr_stage.tscn").instantiate()
		stage_scene.global_position = $Markers/Stages.get_child(i).global_position
		$Stages.add_child(stage_scene)
		stage_scene.stage_cleared.connect(_on_stage_cleared)
		stage_scene.stage_failed.connect(_on_stage_failed)
		failure_count[stage_scene] = 0
	
	set_up_stages()
	
	play_intro()


func set_up_stages():
	for stage_index in range($Stages.get_child_count()):
		var stage: NFRStage = $Stages.get_child(stage_index)
		stage.num_letters = num_letters[stage_index]
		
		# add trick question for the last one
		if stage_index == $Stages.get_child_count() - 1:
			stage.add_question = true
		
		# lower difficulty if failed too many times
		if stage_index == 2:
			if self.failure_count[stage] >= 5:
				stage.num_letters -= 1
		elif stage_index == 3:
			if self.failure_count[stage] >= 3:
				play_end_scene()
		
		if stage_index <= cleared_stages.size():
			stage.enable()
		else:
			stage.disable()


func _on_stage_cleared(stage):
	if not cleared_stages.has(stage):
		cleared_stages.append(stage)
	
	player.set_label("NICE! NEXT!", Vector2(0.8, 0.8))
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position:x", player.global_position.x - 100, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(2).timeout
	player.hide_label()
	
	player.state = Player.PlayerState.NORMAL
	set_up_stages()


func _on_stage_failed(stage):
	
	failure_count[stage] += 1
	
	await get_tree().create_timer(1).timeout
	if not hit_clear_condition():
		player.set_label("TRY AGAIN!", Vector2(0.8, 0.8))
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position:x", player.global_position.x - 100, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if not hit_clear_condition():
		player.state = Player.PlayerState.NORMAL
		await get_tree().create_timer(2).timeout
		player.hide_label()
	
	set_up_stages()


func hit_clear_condition():
	# if cleared first 3 stages and failed the 4th stage 3 times
	return cleared_stages.size() == 3 and failure_count[$Stages.get_child(3)] >= 3


func play_intro():
	Utils.fade_in_screen($GUI)
	await get_tree().create_timer(1).timeout
	
	player.set_animation("default")
	player.state = Player.PlayerState.CONTROL_DISABLED
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/PlayerStop.global_position, 1)
	await tween.finished
	await get_tree().create_timer(1).timeout
	player.state = Player.PlayerState.NORMAL
	

func play_end_scene():
	$GUI/SubInstructions.hide()
	player.set_animation("uh")
	
	await get_tree().create_timer(1).timeout
	$GUI/ClearLabel.show()
	$GUI/ClearLabel.text = ""
	#$GUI/ClearLabel.set_text("THAT WAS IMPOSSIBLE!")
	await get_tree().create_timer(2).timeout
	#$GUI/ClearLabel.text += "\n\nWE CAN'T PASS THIS NFR."
	#await get_tree().create_timer(2).timeout
	#$GUI/ClearLabel.text += "\n\nTIME TO GO NEGOTIATE WITH THE STAKEHOLDERS!"
	await type_text($GUI/ClearLabel, "THAT WAS IMPOSSIBLE!\n\nWE CAN'T PASS THIS NFR!\n\nTIME TO GO NEGOTIATE WITH THE STAKEHOLDERS!")
	
	await get_tree().create_timer(2).timeout
	
	Utils.fade_out_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(2).timeout
	
	get_tree().change_scene_to_file("res://dodge/dodge.tscn")


func type_text(label: Label, full_text: String, delay: float = 0.05) -> void:
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(delay).timeout
