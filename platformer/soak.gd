extends Node2D

const LIMIT_LEFT = 0
signal dialog_line_finished

enum Scene {
	PLATFORM,
	SOAK,
	LEEK,
	WIN,
	END,
}
var current_scene = Scene.PLATFORM
var in_dialog: bool = false

@export var collected_apis: int = 0
var total_apis: int = 5
@onready var player: Player = $Player
@onready var scene_triggers = $SceneTriggers
@onready var dialog = $GUI/Dialog
@onready var change_window = $End/Window
@onready var tire = $End/Tire


func _ready():
	
	player.vertical_enabled = false
	player.state = Player.PlayerState.CONTROL_DISABLED
	player.set_camera_offset(Vector2(0, -64))
	player.set_camera_zoom(2.0)
	player.global_position = $Markers/PlayerInitial.global_position
	player.set_animation("default")
	
	var camera = $Player/Camera2D
	camera.limit_left = LIMIT_LEFT
	
	for node in $Collectibles/APIs.get_children():
		node.collected.connect(_on_api_collected)
	
	$Player.player_died.connect(bounce_player)
	scene_triggers.shooting_start.connect(_on_shooting_start)
	$Plank.leeks_squashed.connect(_on_leeks_squashed)
	
	# hide leeks
	for leek in $Leeks.get_children():
		leek.visible = false
	
	# hide dialog
	dialog.hide()
	
	# hide window
	change_window.modulate.a = 0
	
	await Utils.fade_in_screen($GUI, Color(1, 1, 1))
	
	play_intro()


func _process(_delta: float) -> void:
	# when player is dead, bounce back to starting location
	if $Player.state == $Player.PlayerState.DEAD:
		$Player.position = $PathToStart/PathFollow2D/Node2D.global_position
	
	elif current_scene == Scene.END:
		if $PathToFinish/PathFollow2D.progress_ratio < 1:
			$Player.position = $PathToFinish/PathFollow2D/Node2D.global_position


func _input(_event: InputEvent) -> void:
	if in_dialog:
		if not dialog.dialog_typing:
			if Input.is_action_just_pressed("continue"):
				dialog_line_finished.emit()
		

func play_intro():
	player.state = player.PlayerState.CONTROL_DISABLED
	player.set_animation("default")
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/PlayerStart.global_position, 4)
	tween.play()
	await tween.finished
	player.state = player.PlayerState.NORMAL
	
	
func _on_api_collected():
	"""Update counter."""
	collected_apis += 1
	$GUI/Status/APICount.text = "%s/%s" % [str(collected_apis), str(total_apis)]
	Utils.flash_label($GUI/Status/APICount, 4)


func bounce_player():
	"""Bounce player back to start, play animation, and restart the level."""
	
	# set up bezier curve to go from dead location to start
	var curve = Curve2D.new()
	var p0 = $Player.global_position
	var p2 = $Markers/PlayerStart.global_position
	var p1 = (p0 + p2) / 2
	p1.y -= 300
	curve.add_point(p0, Vector2.ZERO, Vector2(0, -180))
	curve.add_point(p1, Vector2(180, 0), Vector2(-180, 0))
	curve.add_point(p2, Vector2(0, 180), Vector2.ZERO)
	$PathToStart.set_curve(curve)
	
	# play the tween to path follow back to start
	# this moves node2d under the path follow, player is moved in _process to follow
	var tween = get_tree().create_tween()
	tween.tween_property($PathToStart/PathFollow2D, "progress_ratio", 1.0, 2)
	tween.play()
	await tween.finished
	if tween:
		tween.kill()
	
	# flash the player body
	tween = get_tree().create_tween()
	tween.tween_property($Player, "modulate:a", 0, 0.1)
	tween.tween_property($Player, "modulate:a", 1, 0.1)
	tween.set_loops(4)
	tween.play()
	await tween.finished
	if tween:
		tween.kill()

	$Player.set_label("CRASHED!")
	
	await get_tree().create_timer(1).timeout
	
	# revive the player and reset death bounce path
	$Player.revive()
	$Player.hide_label()
	$PathToStart/PathFollow2D.progress_ratio = 0


func animate_label_change(label: Label, to_text: String):
	"""Label pops up to middle of screen, change text, and goes back."""
	var starting_position = label.position
	#var center_position = Vector2(get_viewport().size / 2) - label.size / 2
	var center_position = Vector2(100, 200)
	var t = 0.3
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_callback(label.set_text.bind(to_text))
	tween.tween_property(label, "position", center_position, t).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "scale", Vector2(2, 2), t).set_ease(Tween.EASE_IN)
	tween.play()
	
	await tween.finished
	tween.kill()
	await get_tree().create_timer(1).timeout
	
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(label, "position", starting_position, t).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "scale", Vector2(1, 1), t).set_ease(Tween.EASE_IN)
	tween.play()
	
	await tween.finished
	tween.kill()


func play_soak_animation():
	
	var tween = get_tree().create_tween()
	
	player.state = Player.PlayerState.CONTROL_DISABLED
	
	# walk to onsen
	player.set_animation("default")
	tween.tween_property(player, "global_position", Vector2(2360, -300), 0.3)  # jump up
	tween.tween_property(player, "global_position", Vector2(2390, -220), 0.3)  # jump in onsen
	tween.tween_method(player.set_camera_zoom, 2.0, 3.0, 1).set_ease(Tween.EASE_IN_OUT)  # jump in onsen
	tween.play()
	
	await tween.finished
	player.set_animation("onsen")
	await get_tree().create_timer(9).timeout
	
	if tween:
		tween.kill()
	
	# jump up after soak
	tween = get_tree().create_tween().set_parallel()
	tween.tween_method(player.set_camera_zoom, 3.0, 2.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "global_position", Vector2(2390, -290), 0.3).set_ease(Tween.EASE_OUT)  # jump in onsen
	tween.play()
	
	player.state = Player.PlayerState.FLOATING
	player.set_animation("float")


func play_grow_leek_animation():

	for leek: Leek in $Leeks.get_children():
		leek.visible = true
		leek.set_animation("grow")
		await get_tree().create_timer(1).timeout
		leek.set_animation("default")


func _on_shooting_start():
	player.global_position = $Markers/PlayerCanonShoot.global_position
	$Player.state = Player.PlayerState.CONTROL_DISABLED
	$Canon.enabled = true
	current_scene = Scene.LEEK
	
	# change instructions
	$GUI/Controls.hide()
	$GUI/SubInstructions.visible = true
	drop_celery()


func drop_celery():
	while current_scene == Scene.LEEK:
		var celery = preload("res://platformer/celery_worker.tscn").instantiate()
		#celery.position = Vector2($Celeries/Spawner.shape.extents.x * randf() - $Celeries/Spawner.shape.extents.x / 2,  0)
		var rand_x = randf_range($Celeries/SpawnLeftBound.position.x, $Celeries/SpawnRightBound.position.x)
		var y = $Celeries/SpawnLeftBound.position.y
		celery.position = Vector2(rand_x, y)
		$Celeries/Spawner.add_child(celery)
		await get_tree().create_timer(randf() + 2).timeout


func _on_leeks_squashed():
	# disable leek spawning
	current_scene = Scene.WIN
	
	# disable canon
	$Canon.enabled = false
	$Canon.set_canon_rotation_degrees(-45)
	
	# change remaining celeries animation
	for celery in $Celeries/Spawner.get_children():
		if celery is CeleryWorker:
			celery.set_animation("win")
	
	# change text
	animate_label_change($GUI/Instructions, "MEMORY LEEKS SQUASHED!")
	$GUI/SubInstructions.visible = false
	await get_tree().create_timer(1).timeout
	
	# zoom in on celeries
	var scene_offset = $Player/Camera2D.offset
	var scene_zoom = $Player/Camera2D.zoom.x
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_method($Player.set_camera_offset, scene_offset, Vector2(500, 400), 1)
	tween.tween_method($Player.set_camera_zoom, scene_zoom, 1.0, 1)
	tween.play()
	await tween.finished
	await get_tree().create_timer(2).timeout
	tween.kill()
	
	# go back to robson
	tween = get_tree().create_tween().set_parallel()
	tween.tween_method($Player.set_camera_offset, Vector2(500, 400), Vector2(0, -64), 1)
	tween.tween_method($Player.set_camera_zoom, 1.0, 2.0, 1)
	tween.play()
	await tween.finished
	tween.kill()
	
	# robson backs up
	$Player.set_animation("default")
	var canon_in = Vector2(3056, -248)
	tween = get_tree().create_tween()
	tween.tween_property($Player, "position:x", $Player.position.x - 200, 1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.5)
	tween.play()
	await tween.finished
	tween.kill()
	
	# robson jumps into the canon
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Player, "position", canon_in, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Player, "rotation_degrees", 90, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished
	tween.kill()
	
	# canon shoots
	await get_tree().create_timer(0.5).timeout
	$Canon.set_animation("shoot")
	await get_tree().create_timer(1).timeout
	
	# reset robson
	$Player.set_animation("float")
	
	# robson goes to finish line
	current_scene = Scene.END
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property($PathToFinish/PathFollow2D, "progress_ratio", 1.0, 3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method($Player.set_camera_offset, $Player/Camera2D.offset, Vector2(0, -64), 2)
	tween.tween_method($Player.set_camera_zoom, $Player/Camera2D.zoom.x, 2.0, 2)
	tween.tween_property($Player, "rotation_degrees", 720, 2)
	tween.tween_property($Plank/PlankMountain, "visible", false, 1)
	tween.play()
	await tween.finished
	tween.kill()
	
	# robson goes forward a little
	$Player.set_animation("brake")
	tween = get_tree().create_tween()
	tween.tween_property($Player, "global_position", $Markers/PlayerSlideStop.global_position, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	player.set_animation("default")
	player.sprite.pause()
	
	# zoom camera
	tween = get_tree().create_tween().set_parallel()
	tween.tween_method(player.set_camera_zoom, player.camera.zoom.x, 1.5,  1).set_ease(Tween.EASE_OUT)
	tween.tween_method(player.set_camera_offset, player.camera.offset, Vector2(150, -64),  1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	# stakeholder speaks
	in_dialog = true
	dialog.show()
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "YOU PASSED THE LAST TEST! WELL DONE!")
	#await get_tree().create_timer(4).timeout
	await dialog_line_finished
	# open change window
	tween = get_tree().create_tween()
	tween.tween_property(change_window, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT)
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "THE CHANGE WINDOW IS NOW OPEN!")
	#await get_tree().create_timer(4).timeout
	await dialog_line_finished
	dialog.show_dialog(Dialog.Character.STAKEHOLDER, "TIME TO LAUNCH!")
	#await get_tree().create_timer(4).timeout
	await dialog_line_finished
	dialog.hide()
	in_dialog = false
	
	# robson steps on tire
	player.set_animation("float")
	tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $End/Markers/OnTire.global_position, 0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	await get_tree().create_timer(1).timeout
	
	# fly up
	tween = get_tree().create_tween().set_parallel()
	var tire_offset = $End/Markers/OnTire.global_position - $End/Markers/TireInitial.global_position 
	tween.tween_property(player, "global_position", $End/Markers/Window.global_position + tire_offset, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(tire, "global_position", $End/Markers/Window.global_position, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(player, "modulate:a", 0, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.2)
	tween.tween_property(tire, "modulate:a", 0, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.2)
	tween.play()
	
	await tween.finished
	
	# flash screen and transition
	await Utils.fade_out_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://outro/outro.tscn")
	
	# give robson movement
	#$Player.set_state(Player.PlayerState.NORMAL)
	#$Player.set_animation("default")
