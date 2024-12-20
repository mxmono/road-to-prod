extends Node2D

signal light_changed

var max_lights: int = 5
var coverage_target: float = 0.7
var cleared = false
var input_disabled = false

enum Stage {
	INTRO,
	PLAYING,
	CLEARED,
}

var current_stage = Stage.INTRO
@onready var player = $Player


func _ready() -> void:
	player.state = Player.PlayerState.CONTROL_DISABLED
	player.global_position = $Markers/Initial.global_position
	
	calc_overlap()
	$UI/Group.modulate.a = 0
	$UI/Grid.hide()
	$Lights.child_entered_tree.connect(_on_light_added)
	$Lights.child_exiting_tree.connect(_on_light_deleted)
	light_changed.connect(_on_light_changed)
	$Map/Trigger.body_entered.connect(_on_trigger_entered)
	$Map/NextStageTrigger.body_entered.connect(_on_next_stage_triggered)
	
	$Player.vertical_enabled = true
	$Player.disable_camera()

	play_intro()


func play_intro():
	
	# fade in
	Utils.fade_in_screen($".")
	await get_tree().create_timer(1).timeout
	
	# robson walks in
	player.set_animation("default")
	player.global_position = $Markers/Initial.global_position
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", $Markers/Start.global_position, 2)
	tween.play()
	await tween.finished
	
	player.state = player.PlayerState.NORMAL


func _input(event):
	
	if input_disabled:
		return
	
	if $Lights.get_child_count() >= self.max_lights:
		return
	
	# add light at clicked position
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# if not in game
		if not current_stage == Stage.PLAYING:
			return
		
		var clicked_tile: Vector2i = $Map.local_to_map($Map.get_local_mouse_position())
		var data: TileData = $Map.get_cell_tile_data(clicked_tile)
		var light_rotation = data.get_custom_data("light_rotation")
		if light_rotation != -1:
			# if it's a corner tile with two possible places:
			if int(light_rotation) % 90 == 45:
				var adjusted_rotation = 0
				match light_rotation:
					45: adjusted_rotation = 0 if int(event.position.y) % 64 > 32 else 90
					135: adjusted_rotation = 90 if int(event.position.x) % 64 < 32 else 135
					225: adjusted_rotation = 180 if int(event.position.y) % 64 < 32 else 270
					315: adjusted_rotation = 270 if int(event.position.x) % 64 > 32 else 0
				light_rotation = adjusted_rotation
			#print(light_rotation)
			var offset = Vector2(0, 0)
			match light_rotation:
				0: offset = Vector2(-32, -32)
				90: offset = Vector2(32, -32)
				180: offset = Vector2(32, 32)
				270: offset = Vector2(-32, 32)
			
			# if already has a light, don't add one
			for light in $Lights.get_children():
				if $Map.map_to_local(clicked_tile) * 4 + offset == light.position:
					return
			
			var script = preload("res://coverage/light_cone.tscn") if $UI/Group/ConeButton.button_pressed else preload("res://coverage/light_straight.tscn")
			var new_light = script.instantiate()
			#var new_light = preload("res://light_straight.tscn").instantiate()
			new_light.name = "Light" + str($Lights.get_child_count())
			#print($Map.map_to_local(clicked_tile) * 4)
			new_light.position = $Map.map_to_local(clicked_tile) * 4 + offset
			new_light.rotation_degrees = light_rotation
			
			# wait for light to initialize before casting light to calculte collision correctly
			new_light.visible = false
			$Lights.add_child(new_light)
			input_disabled = true  # there is a glitch where you can quickly install and uninstall a light on winning, the game will crash
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(new_light):
				new_light.cast_light()
				light_changed.emit(new_light)
				new_light.visible = true
			input_disabled = false


func _on_light_added(light: Node):
	_on_light_changed(light)


func _on_light_deleted(light: Node):
	_on_light_changed(light)


func get_num_lights() -> int:
	return $Lights.get_child_count()
	

func _on_light_changed(_new_light):
	await get_tree().create_timer(0.15).timeout
	
	# update light count label
	var num_lights = get_num_lights()
	$UI/Group/LightCount.text = "x%s" % (self.max_lights - num_lights)
	if num_lights >= self.max_lights:
		$UI/Group/LightCount.label_settings.font_color = Color("e17cb7")
	else:
		$UI/Group/LightCount.label_settings.font_color = Color("white")
	
	# calulate coverage
	var coverage = calc_overlap()
	
	# disable place lights button if lights are out
	if num_lights >= self.max_lights:
		$UI/Group/ConeButton.disabled = true
		$UI/Group/StraightButton.disabled = true
	else:
		$UI/Group/ConeButton.disabled = false
		$UI/Group/StraightButton.disabled = false
	
	# check if wins
	if coverage >= self.coverage_target:
		self.cleared = true
		current_stage = Stage.CLEARED
		disable_actions()
		play_win_animation()
		remove_blocker()


func disable_actions():
	input_disabled = true
	for light in $Lights.get_children():
		light.set("active", false)


func play_win_animation():
	$CanvasModulate/AnimationPlayer.active = true
	for i in range(4):
		$CanvasModulate/AnimationPlayer.play("WinModulate")
		await get_tree().create_timer(0.5).timeout
	$Map/Door.play("open")


func remove_blocker():
	$Map/Block.clear()


func _on_trigger_entered(body):
	if not body is Player:
		return
	
	var tween = get_tree().create_tween()
	$UI/Check.hide()
	tween.tween_property($UI/Group, "modulate:a", 1, 1)
	$UI/Grid.show()
	current_stage = Stage.PLAYING


func _on_next_stage_triggered(body):
	if body is Player:
		Utils.fade_out_screen($".")
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://functional/functional.tscn")
	

func get_light_node_cell_to_map_cell(light_node: Node, light_node_cell_coords: Vector2i) -> Vector2i:
	"""Given a light node and the cell coord within light node, get the cell coord on the map."""
	var cell_coords = $Map.local_to_map(
		light_node.to_global(
			light_node.get_local_cell_position(light_node_cell_coords)
		) 
	) / $Map.scale.x
	
	return cell_coords

	
func calc_overlap() -> float:
	"""Calculate % covered and update label."""
	var full_light_cells = []
	var half_light_cells = []
	
	for light_node: Node2D in $Lights.get_children():
		var light_cells: Dictionary = light_node.get_light_cells()

		for full_light_cell: Vector2i in light_cells["full"]:
			var map_cell = get_light_node_cell_to_map_cell(light_node, full_light_cell)
			if not full_light_cells.has(map_cell):
				full_light_cells.append(map_cell)
				
		for half_light_cell: Vector2i in light_cells["half"]:
			var map_cell = get_light_node_cell_to_map_cell(light_node, half_light_cell)
			if not half_light_cells.has(map_cell):
				half_light_cells.append(map_cell)
	
	# for overlap: remove halfs if already covered by full
	for half_light_cell: Vector2i in half_light_cells:
		if full_light_cells.has(half_light_cell):
			half_light_cells.erase(half_light_cell)
	
	#print("full: ", full_light_cells.size())
	#print("half:", half_light_cells.size())
	
	var total_lit = full_light_cells.size() + 0.5 * half_light_cells.size()
	var total_valid_area = $Map.get_used_cells_by_id(0, Vector2i(2, 2), 0).size()
	var coverage: float = total_lit / float(total_valid_area)
	
	$UI/Group/ResultLabel.text = "%s TOTAL TILES\n%s LIT TILES" % [str(total_valid_area), str(total_lit)]
	$UI/Group/ResultLabel.text += "\n" + str($Lights.get_child_count()) + " LAMPS INSTALLED"
	$UI/Group/ResultPctLabel.text = "%d%%" % (coverage * 100)
	
	return coverage
