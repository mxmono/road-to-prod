extends Node2D

signal playfield_entered()
signal won()
signal stage_cleared()

@export var targets_lit: int = 0
var total_targets = 5
enum State {
	INTRO,
	PLAYING,
	PORTAL_OPEN,
	OUTRO,
}
var current_state = State.PLAYING

@onready var main_scene = $".."
@onready var suck = $Props/Suck


func _ready() -> void:
	
	# link collector for respawn
	$Collector.player_collected.connect(_on_player_collected)
	
	# link target collection
	for target: PinballTarget in $Props/Collectibles.get_children():
		target.target_lit.connect(_on_target_lit)
	
	# init label
	$Stats.text = "%s/%s" % [targets_lit, total_targets]
	
	# init ending animation sprites
	$Props/Portal/Portal.modulate.a = 0
	$Props/Portal/Flash.modulate.a = 0
	
	# connect portal area detection
	$Props/Portal/PortalArea.body_entered.connect(_on_portal_entered)
	
	# connect entrance area detection (remove blocker after entering the field)
	$Table/EntranceArea.body_entered.connect(_on_playfield_entered)
	enable_entrance()
	
	# disable controls
	disable_controls()
	
	# connect suck
	suck.body_entered.connect(_on_suck_entered)
	
	# connect main scene signal for game start
	main_scene.pinball_started.connect(_on_pinball_started)


func _on_player_collected():
	if current_state == State.PLAYING or current_state == State.PORTAL_OPEN:
		await get_tree().create_timer(0.5).timeout
		spawn_player()


func _on_portal_entered(body):
	if targets_lit < total_targets:
		return
	
	# go to next stage
	if body is PlayerBall:
		
		if not current_state == State.PORTAL_OPEN:
			return
		
		# player goes to the center of the portal
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property(body, "position", $Markers/Portal.position, 1)
		tween.tween_property(body, "rotation_degrees", 0, 1)
		tween.play()
		await tween.finished
		tween.kill()
		if body != null and is_instance_valid(body):
			body.queue_free()
		
		current_state = State.OUTRO
		show_portal_animation()


func _on_suck_entered(body):
	if body is PlayerBall:
		body.apply_central_impulse(Vector2(50, -50))
	

func _on_pinball_started():
	enable_controls()
	spawn_player()


func disable_controls():
	$FlipperL.enabled = false
	$FlipperR.enabled = false
	$Props/Spring.enabled = false


func enable_controls():
	$FlipperL.enabled = true
	$FlipperR.enabled = true
	$Props/Spring.enabled = true


func enable_entrance():
	# when player comes up from the tube, needs to go through
	$Table/EntranceBlock.set_deferred("disabled", true)
	# area monitoring needs to be on to detect player enters playfield
	$Table/EntranceArea.set_deferred("monitoring", true)


func disable_entrance():
	# while player is playing in playfield, turn on entrance block (like wall)
	$Table/EntranceBlock.set_deferred("disabled", false)
	# stop monitoring if player entered entrance area
	$Table/EntranceArea.set_deferred("monitoring", false)


func _on_playfield_entered(body):
	if body is PlayerBall:
		playfield_entered.emit()
		disable_entrance()


func remove_ball():
	for node in $PlayerNode.get_children():
		node.queue_free()


func spawn_player():

	remove_ball()
	
	enable_entrance()
	
	var player: PlayerBall = preload("res://player_ball.tscn").instantiate()
	player.position = $Markers/Spawner.position
	$PlayerNode.add_child(player)


func _on_target_lit():
	targets_lit += 1
	$Stats.text = "%s/%s" % [targets_lit, total_targets]
	if targets_lit >= total_targets:
		if current_state == State.PLAYING:
			activate_portal()
			current_state = State.PORTAL_OPEN
			won.emit()


func activate_portal():
	var portal = $Props/Portal/Portal
	var flash = $Props/Portal/Flash
	
	var tween = get_tree().create_tween()
	
	# show portal
	portal.play("still")
	tween.tween_property(portal, "modulate:a", 1, 0.2)
	await get_tree().create_timer(1).timeout
	
	# play portal open animation
	portal.play("open")
	await get_tree().create_timer(0.5).timeout
	
	# show flash anime
	flash.modulate.a = 1
	flash.play()
	
	# show label
	$Props/Portal/WinLabel.show()
	$Props/Portal/WinLabel.text = "COME\nIN"


func show_portal_animation():
	"""Static animation mimicking player descending into portal."""
	var player_sprite = $Props/Portal/PlayerSprite
	
	player_sprite.show()
	
	var tween = get_tree().create_tween().set_loops(3)
	$Props/Portal/WinLabel.text = "YAY"
	tween.tween_property($Props/Portal/WinLabel, "visible", true, 0.1).set_delay(0.2)
	tween.tween_property($Props/Portal/WinLabel, "visible", false, 0.1).set_delay(0.2)
	tween.play()
	await tween.finished
	await get_tree().create_timer(2).timeout
	
	tween = get_tree().create_tween()
	tween.tween_property($Props/Portal/PlayerSprite, "global_position", $Markers/PortalBottom.global_position, 1)
	await tween.finished
	
	player_sprite.hide()
	
	stage_cleared.emit()
