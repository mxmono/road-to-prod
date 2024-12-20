extends Node2D

signal dialog_line_finished

var num_features: int = 0
var num_bugfixes: int = 0

enum Stage {
	INTRO,
	READY,
	PLAYING,
	OUTRO,
}
var current_stage = Stage.INTRO
var in_dialog: bool = false

@onready var start_timer: Timer = $Timer
@onready var player: PlayerSki = $RobsonSki

@onready var snowball_trigger: Area2D = $Map/Triggers/Snowball
@onready var snowball_exit_trigger: Area2D = $Map/Triggers/SnowballExit
@onready var snowball_spawner: Node2D = $Map/Spawners/Snowball
@onready var snowball_timer: Timer = $Map/Triggers/Snowball/Timer
@onready var snow_particle: CPUParticles2D = $RobsonSki/Snow

@onready var outro_trigger: Area2D = $Map/Triggers/Exit
@onready var dialog: Dialog = $GUI/Dialog


func _ready() -> void:
	
	#get_tree().paused = false
	player.global_position = $Markers/Initial.global_position
	
	# hide clear label
	$GUI/StartIndicator.hide()
	$GUI/Clear.modulate.a = 0
	dialog.hide()
	
	# hide ending anime assets
	for node in $Map/Triggers/Exit/AnimeAssets.get_children():
		node.hide()
	
	for node in $Map/Collectibles.get_children():
		node.collected.connect(_on_item_collected)
		
	snowball_trigger.body_entered.connect(_on_snowball_triggered)
	snowball_exit_trigger.body_entered.connect(_on_snowball_exit_triggered)
	
	start_timer.timeout.connect(_on_start_timer_timeout)
	start_timer.wait_time = 2.0
	
	snowball_timer.timeout.connect(_on_snowball_timer_timeout)
	
	outro_trigger.body_entered.connect(_on_outro_triggered)
	
	await play_intro()


func _input(_event: InputEvent) -> void:
	if current_stage == Stage.READY:
		if Input.is_action_just_released("continue"):
			start_timer.stop()
		if Input.is_action_just_pressed("continue"):
			start_timer.start()
	
	if in_dialog:
		if not dialog.dialog_typing:
			if Input.is_action_just_pressed("continue"):
				dialog_line_finished.emit()


func _process(_delta: float) -> void:
	if current_stage == Stage.READY:
		$GUI/StartIndicator/StartProgress.size.x = $GUI/StartIndicator.size.x * (1 - start_timer.time_left / start_timer.wait_time)


func play_intro():
	# fade in
	Utils.fade_in_screen($GUI, Color(1, 1, 1))
	
	# robson walks
	player.sprite.play("sidewalk")
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/SkiStart.global_position, 4)
	await tween.finished
	await get_tree().create_timer(1).timeout
	
	player.sprite.play("ski")
	player.sprite.pause()
	
	current_stage = Stage.READY
	$GUI/StartIndicator.show()
	

func _on_start_timer_timeout():
	# start skiing
	current_stage = Stage.PLAYING
	player.state = player.State.SKI
	$GUI/StartIndicator.hide()
	
	player.sprite.play("ski")
	

func _on_item_collected(item):
	if item is SkiFeature:
		num_features += 1
	elif item is SkiBug:
		num_bugfixes += 1
	
	player.flash_label()
	
	update_stats_label()


func update_stats_label():
	# flash label
	var tween = get_tree().create_tween().set_loops(2)
	tween.tween_property($GUI/Stats, "modulate", Color("92e5a9"), 0.1)
	tween.tween_property($GUI/Stats, "modulate", Color("0c799a"), 0.1)
	tween.play()
	
	$GUI/Stats.text = "FEATURES: %s\nBUGFIXES: %s" % [num_features, num_bugfixes]


func _on_snowball_triggered(body):
	if body is PlayerSki:
		snowball_timer.start()
		# snows harder
		snow_particle.speed_scale = 10
		snow_particle.scale_amount_max = 5
		snow_particle.scale_amount_max = 20


func _on_snowball_exit_triggered(body):
	if body is PlayerSki:
		snowball_timer.stop()
		# back to normal snow
		snow_particle.speed_scale = 2
		snow_particle.scale_amount_max = 2
		snow_particle.scale_amount_max = 5


func spawn_snowballs():
	var snowball = preload("res://dev/snowball.tscn").instantiate()
	snowball_spawner.add_child(snowball)
	# if player is below the spawner
	if player.global_position.y > snowball_spawner.global_position.y:
		snowball.global_position.y = player.global_position.y - 300
		snowball.global_position.x = randf_range($Map/Spawners/Snowball/L.global_position.x, $Map/Spawners/Snowball/R.global_position.x)


func _on_snowball_timer_timeout():
	spawn_snowballs()
	snowball_timer.start()


func _on_outro_triggered(body):
	
	if not body is PlayerSki:
		return
	
	player.state = player.State.CONTROL_DISABLED
	
	if num_features + num_bugfixes <= 0:
		$GUI/Clear.modulate.a = 1
		#get_tree().paused = true
		await get_tree().create_timer(4).timeout
		get_tree().reload_current_scene()
		return
	
	current_stage = Stage.OUTRO
	play_outro()


func play_outro():
	
	player.state = player.State.CONTROL_DISABLED
	player.sprite.play("walk")
		
	# camera zoom
	var tween = get_tree().create_tween()
	tween.tween_property(player.camera, "zoom", player.camera.zoom * 1.2, 1).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween.kill()
	
	# hide instructions to clean up ui
	$GUI/StageName.hide()
	$GUI/Instructions.hide()
	$GUI/Instructions/Controls.hide()
	
	# robson walks over
	tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Map/Triggers/Exit/WalkStop.global_position, 3)
	await tween.finished
	tween.kill()
	
	await get_tree().create_timer(2).timeout
	
	# block appeared
	var glass = $Map/Triggers/Exit/AnimeAssets/Glass
	var glass_shadow = $Map/Triggers/Exit/AnimeAssets/GlassShadow
	
	glass.global_position = $Map/Triggers/Exit/GlassInitial.global_position
	tween = get_tree().create_tween()
	glass.show()
	glass_shadow.show()
	tween.tween_property(glass, "global_position", $Map/Triggers/Exit/GlassEnd.global_position, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	player.sprite.play("shock")
	await tween.finished
	$Map/Triggers/Exit/AnimeAssets/Glass/Snowsplash.play("default")
	$Map/Triggers/Exit/AnimeAssets/Glass/Snowsplash2.play("default")
	
	tween.kill()
	
	# ghosty appears
	await get_tree().create_timer(3).timeout
	var ghosty: Stakeholder = $Map/Triggers/Exit/AnimeAssets/Stakeholder
	ghosty.show()
	ghosty.set_animation("default")
	ghosty.global_position = $Map/Triggers/Exit/GhostyStart.global_position
	
	tween = get_tree().create_tween()
	tween.tween_property(ghosty, "global_position", $Map/Triggers/Exit/GhostyEnd.global_position, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	await tween.finished
	await get_tree().create_timer(1).timeout
	ghosty.set_animation("stake")
	
	# dialogs
	in_dialog = true
	dialog.show()
	dialog.show_dialog(Dialog.Character.GHOSTY, "NOT SO FAST!")
	#await get_tree().create_timer(4).timeout
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.GHOSTY, "YOU SAY YOU HAVE %s FEATURES AND %s BUGS TO RELEASE??" % [num_features, num_bugfixes])
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.GHOSTY, "YOU NEED TO GO THROUGH TESTING FIRST!")
	await dialog_line_finished
	
	dialog.show_dialog(Dialog.Character.ROBSON, "....")
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.ROBSON, "OK! NOTHING CAN BEAT ME!")
	await dialog_line_finished
	in_dialog = false
	
	# fade out screen
	Utils.fade_out_screen($GUI/FadeHolder)
	await get_tree().create_timer(3).timeout
	
	# show text
	var transition_text = $GUI/TransitionText
	tween = get_tree().create_tween()
	tween.tween_property(transition_text, "modulate:a", 1, 2)
	await tween.finished
	
	await get_tree().create_timer(2).timeout
	
	await Utils.fade_out_screen($GUI)
	
	# load next scene
	get_tree().change_scene_to_file("res://coverage/coverage.tscn")
