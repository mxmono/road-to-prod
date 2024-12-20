extends Node2D

enum Stage {
	INRTO,
	P4,
	P3,
	P2,
	USER_ERROR,
	BLOCKER,
	ALL,
	LOLCRY,
}
var stages = [Stage.P4, Stage.P3, Stage.P2, Stage.USER_ERROR, Stage.BLOCKER, Stage.ALL, Stage.LOLCRY]
var stage_index = 0
var current_stage = stages[stage_index]

var spawn_cooldown = {
	Stage.P4: 1,
	Stage.P3: 2,
	Stage.P2: 3,
	Stage.USER_ERROR: 1 ,
	Stage.BLOCKER: 1,
	Stage.ALL: 0.25,
	Stage.LOLCRY: 100,  # only 1
}

@onready var player = $PlayArea/RobsonTire
@onready var screen_white = $PlayArea/White
@onready var portal = $PlayArea/Portal
@onready var stars = $GUI/Stars
@onready var shooting_star_emitter = $GUI/ShootingStar
@onready var shooting_star_timer = $GUI/ShootingStarTimer
@onready var spawn_timer = $SpawnTimer
@onready var stage_timer = $StageTimer
@onready var smashables = $Smashables
@onready var clear_label = $ClearLabel/ClearLabel



func _ready() -> void:
	screen_white.modulate.a = 1
	clear_label.modulate.a = 0
	stars.emitting = true
	player.state = player.State.CONTROL_DISABLED
	player.global_position = $Markers/PlayerInitial.global_position
	
	await play_intro()
	
	spawn_timer.wait_time = 2
	spawn_timer.timeout.connect(_on_spawner_timer_time_out)
	spawn_timer.start()
	
	stage_timer.wait_time = 10
	stage_timer.timeout.connect(_on_stage_timer_time_out)
	stage_timer.start()
	
	shooting_star_timer.wait_time = 3
	shooting_star_timer.timeout.connect(_on_shooting_star_timer_time_out)
	shooting_star_timer.start()


func play_intro():
	# robson shoots in
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(player, "global_position", $Markers/PlayerShoot.global_position, 1)
	tween.tween_property(player, "modulate:a", 0, 0.1).set_delay(0.9)
	tween.play()
	await tween.finished
	tween.kill()
	screen_white.modulate.a = 0
	await Utils.fade_in_screen($GUI, Color(1, 1, 1))
	
	player.modulate.a = 1
	player.global_position = $Markers/PlayerInitial.global_position
	tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/PlayerStart.global_position, 0.5)
	
	player.state = player.State.NORMAL


func spawn_bugs(bug_type: SpaceBug.Bugs):
	
	var bug = preload("res://outro/spacebug.tscn").instantiate()
	bug.bug = bug_type
	bug.position.x = $Markers/Spawner.position.x
	bug.position.y = randf_range(50, 650)
	
	if bug.bug == SpaceBug.Bugs.LOLCRY:
		bug.position.y = 360
		bug.position.x = $Markers/BossSpawner.position.x
		bug.bug_defeated.connect(_on_boss_defeated)
		await get_tree().create_timer(4).timeout  # give it a bit of a gap
	
	smashables.add_child(bug)
	

func _on_spawner_timer_time_out():
	var bug: SpaceBug.Bugs
	match current_stage:
		Stage.P4: bug = SpaceBug.Bugs.P4
		Stage.P3: bug = SpaceBug.Bugs.P3
		Stage.P2: bug = SpaceBug.Bugs.P2
		Stage.USER_ERROR: bug = SpaceBug.Bugs.USER_ERROR
		Stage.BLOCKER: bug = SpaceBug.Bugs.BLOCKER
		Stage.ALL: 
			bug = [
				SpaceBug.Bugs.P4, SpaceBug.Bugs.P4, SpaceBug.Bugs.P4, SpaceBug.Bugs.P4,
				SpaceBug.Bugs.P3,
				SpaceBug.Bugs.P2,
				SpaceBug.Bugs.USER_ERROR, SpaceBug.Bugs.USER_ERROR, SpaceBug.Bugs.USER_ERROR,
				SpaceBug.Bugs.BLOCKER, SpaceBug.Bugs.BLOCKER, SpaceBug.Bugs.BLOCKER,
			].pick_random()
		Stage.LOLCRY: bug = SpaceBug.Bugs.LOLCRY

	spawn_bugs(bug)
	
	if current_stage != Stage.LOLCRY:
		spawn_timer.wait_time = clampf(spawn_cooldown[current_stage] + randf_range(-0.5, 0.5), 0.1, 5)
		spawn_timer.start()
	else:
		spawn_timer.stop()


func _on_stage_timer_time_out():
	stage_timer.wait_time = randf_range(8, 10)
	# make all stage a bit longer
	if current_stage == Stage.ALL:
		stage_timer.wait_time = 15
	stage_timer.start()
	stage_index += 1
	if stage_index < stages.size():
		current_stage = stages[stage_index]


func _on_shooting_star_timer_time_out():
	shooting_star_emitter.emitting = true
	shooting_star_emitter.one_shot = true
	await shooting_star_emitter.finished
	shooting_star_emitter.one_shot = false
	shooting_star_timer.wait_time = randf_range(5, 10)
	shooting_star_timer.start()
	

func _on_boss_defeated():
	play_outro()


func play_outro():
	await get_tree().create_timer(1).timeout
	stars.orbit_velocity_min = 0.1
	stars.orbit_velocity_max = 1
	stars.amount = 200
	stars.speed_scale = 4
	stars.position = $Markers/Portal.position
	portal.show()
	await get_tree().create_timer(2).timeout
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(player, "global_position", $Markers/Portal.global_position, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(player, "modulate:a", 0, 0.1).set_delay(0.9)
	tween.play()
	await tween.finished
	tween.kill()
	
	await Utils.fade_out_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(3).timeout
	
	
	tween = get_tree().create_tween()
	tween.tween_property(clear_label, "modulate:a", 1, 0.5)
	tween.tween_interval(4)
	tween.tween_property(clear_label, "modulate:a", 0, 0.5)
	await tween.finished
	tween.kill()
	
	await get_tree().create_timer(1).timeout
	
	# show thank you slide
	get_tree().change_scene_to_file("res://end.tscn")
