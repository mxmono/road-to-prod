extends LightCone
class_name LightStraight


#@onready var cell_data = $Light.get_tile_map_data_as_array()
#
#var active = true
#var occlusion = {}
#var center = 0
#var height = 12
#var edges = []
#var lamp_atlas_coords = Vector2i(8, 7)
#@onready var lamp_tiles = $Light.get_used_cells_by_id(0, lamp_atlas_coords, 0)
#@onready var full_light_tiles = $Light.get_used_cells_by_id(0, Vector2i(5, 7), 0)
#@onready var left_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(9, 7), 0)
#@onready var right_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(10, 7), 0)
#@onready var all_light_tiles = full_light_tiles + left_half_tiles + right_half_tiles


func _ready() -> void:
	
	active = true
	occlusion = {}
	center = 0
	height = 12
	edges = []
	lamp_atlas_coords = Vector2i(8, 7)
	lamp_tiles = $Light.get_used_cells_by_id(0, lamp_atlas_coords, 0)
	full_light_tiles = $Light.get_used_cells_by_id(0, Vector2i(5, 7), 0)
	right_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(10, 7), 0)
	all_light_tiles = full_light_tiles + left_half_tiles + right_half_tiles
	
	# calculate the occlusion dictionary
	for tile in all_light_tiles:
		occlusion[tile] = calculate_occlusion(tile, all_light_tiles)
	print(occlusion)


#func _input(event):
	#if not self.active:
		#return
	## if right click lamp tiles, delete the light
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		#if $Light.get_cell_atlas_coords(get_local_cell_coords(event.position)) == self.lamp_atlas_coords:
			#queue_free()


#func get_local_cell_coords(_position: Vector2i) -> Vector2i:
	#"""Return the cell position, eg (0, 0) for tile position (0, 0).
	#Adjusted for scale.
	#"""
	#var coords = $Light.local_to_map(to_local(_position) / $Light.scale.x)
	#return coords


#func get_local_cell_position(coords: Vector2i) -> Vector2:
	#return $Light.map_to_local(coords) * $Light.scale.x
	

func calculate_occlusion(occlude_tile: Vector2i, all_tiles: Array):
	"""Based on which tile is blocked (has collision), calculate which other tiles are blocked."""
	
	var blocked_tiles = []

	for tile: Vector2i in all_tiles:
		if tile.x == occlude_tile.x and tile.y > occlude_tile.y:
			if not blocked_tiles.has(tile):
				blocked_tiles.append(tile)
						
	return blocked_tiles


#func cast_light():
	#"""Cast the light and remove cells where the light is blocked."""
	##$Light.set_tile_map_data_from_array(cell_data)
	#adjust_light_cells()


func adjust_light_cells():
	"""Adjust light cells based on where the light is placed."""
	
	var tiles_to_erase = []
	var collision_tile: Vector2i = get_local_cell_coords($Light/RayCast2D.get_collision_point())
	#print(collision_tile)
	tiles_to_erase.append(collision_tile)
	if self.occlusion.has(collision_tile):
		var blocked_tiles = self.occlusion[collision_tile]
		for tile in blocked_tiles:
			if not tiles_to_erase.has(tile):
				tiles_to_erase.append(tile)
	
	# erase tiles
	#print("erase: ", tiles_to_erase)
	for tile in tiles_to_erase:
		$Light.erase_cell(tile)


func get_light_cells() -> Dictionary:
	"""Calculate which tiles are still present for area calculation."""
	
	full_light_tiles = $Light.get_used_cells_by_id(0, Vector2i(5, 7), 0)
	left_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(9, 7), 0)
	right_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(10, 7), 0)
	
	#self.covered_area = full_light_tiles + 0.5 * left_half_tiles + 0.5 * right_half_tiles
	
	return {
		"full": full_light_tiles,
		"half": left_half_tiles + right_half_tiles,
	}
