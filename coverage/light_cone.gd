extends Node2D
class_name LightCone


@onready var cell_data = $Light.get_tile_map_data_as_array()

var active = true
var occlusion = {}
#var occlusion = {
	#Vector2i(1, 1): [Vector2i(0, 2), Vector2i(1, 2)],
	#Vector2i(2, 1): [Vector2i(1, 1), Vector2i(3, 1), Vector2i(0, 2) , Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2)],
	#Vector2i(3, 1): [Vector2i(3, 2), Vector2i(4, 2)],
	#Vector2i(1, 2): [Vector2i(0, 2)],
	#Vector2i(2, 2): [],
	#Vector2i(3, 2): [Vector2i(4, 2)],
#
#}

var center = 0
var height = 3
var edges = []
#var edges = [
	#Vector2i(center - 1, 1), Vector2i(center + 1, 1),
	#Vector2i(center - 2, 2), Vector2i(center + 2, 2),
#]
var lamp_atlas_coords = Vector2i(8, 7)
@onready var lamp_tiles = $Light.get_used_cells_by_id(0, lamp_atlas_coords, 0)
@onready var full_light_tiles = $Light.get_used_cells_by_id(0, Vector2i(5, 7), 0)
@onready var left_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(9, 7), 0)
@onready var right_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(10, 7), 0)
@onready var all_light_tiles = full_light_tiles + left_half_tiles + right_half_tiles


func _ready() -> void:
	# calculate edges
	edges = []
	for row in range(height):
		edges += [Vector2i(center - (row + 1), row + 1), Vector2i(center + (row + 1), row + 1)]
	#print(edges)
	
	# calculate the occlusion dictionary
	for tile in all_light_tiles:
		occlusion[tile] = calculate_occlusion(tile, all_light_tiles)
	#print(occlusion)


func _input(event):
	if not self.active:
		return
	# if right click lamp tiles, delete the light
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if $Light.get_cell_atlas_coords(get_local_cell_coords(event.position)) == self.lamp_atlas_coords:
			queue_free()


func get_local_cell_coords(_position: Vector2i) -> Vector2i:
	"""Return the cell position, eg (0, 0) for tile position (0, 0).
	Adjusted for scale.
	"""
	var coords = $Light.local_to_map(to_local(_position) / $Light.scale.x)
	return coords


func get_local_cell_position(coords: Vector2i) -> Vector2:
	return $Light.map_to_local(coords) * $Light.scale.x


func get_blocked_tiles_from_edge(occlude_tile: Vector2i, all_tiles: Array) -> Array:
	var blocked_tiles = []
	# if an edge is occluded
	if edges.has(occlude_tile):
		# if it's left, then tiles below below and left are blocked
		if occlude_tile.x < center:
			for tile: Vector2i in all_tiles:
				if tile.x <= occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
		
		# if it's right, then tiles below and right are blocked
		elif occlude_tile.x > center:
			for tile: Vector2i in all_tiles:
				if tile.x >= occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
		
		# if it's in the middle, only lower tiles are blocked
		else:
			for tile: Vector2i in all_tiles:
				if tile.x == occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
	
	return blocked_tiles
	

func calculate_occlusion(occlude_tile: Vector2i, all_tiles: Array):
	"""Based on which tile is blocked (has collision), calculate which other tiles are blocked."""
	
	var blocked_tiles = []
	
	# if an edge is occluded
	if edges.has(occlude_tile):
		# if it's left, then tiles below below and left are blocked
		if occlude_tile.x < center:
			for tile: Vector2i in all_tiles:
				if tile.x <= occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
		
		# if it's right, then tiles below and right are blocked
		elif occlude_tile.x > center:
			for tile: Vector2i in all_tiles:
				if tile.x >= occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
		
		# if it's in the middle, only lower tiles are blocked
		else:
			for tile: Vector2i in all_tiles:
				if tile.x == occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
		
	# if it's not edge
	else:
		# if the tile right underneath the light is blocked, all is blocked
		if occlude_tile == Vector2i(center, 1):
			blocked_tiles = all_tiles
			blocked_tiles.erase(occlude_tile)  # remove self
		
		# if the tile is only 1 from the L/R edge, then the L/R edge is also blocked
		if edges.has(Vector2i(occlude_tile.x - 1, occlude_tile.y)):  # left
			blocked_tiles.append(Vector2i(occlude_tile.x - 1, occlude_tile.y))
			for tile in get_blocked_tiles_from_edge(Vector2i(occlude_tile.x - 1, occlude_tile.y), all_tiles):
				if not blocked_tiles.has(tile):
					blocked_tiles.append(tile)
		elif edges.has(Vector2i(occlude_tile.x + 1, occlude_tile.y)):  # right
			blocked_tiles.append(Vector2i(occlude_tile.x + 1, occlude_tile.y))
			for tile in get_blocked_tiles_from_edge(Vector2i(occlude_tile.x + 1, occlude_tile.y), all_tiles):
				if not blocked_tiles.has(tile):
					blocked_tiles.append(tile)
		
		# if it's not directly below the source, only lower tiles are blocked
		else:
			for tile: Vector2i in all_tiles:
				if tile.x == occlude_tile.x and tile.y > occlude_tile.y:
					if not blocked_tiles.has(tile):
						blocked_tiles.append(tile)
						
	return blocked_tiles


func cast_light():
	"""Cast the light and remove cells where the light is blocked."""
	#$Light.set_tile_map_data_from_array(cell_data)
	adjust_light_cells()
	
	calculate_covered_area()


func adjust_light_cells():
	"""Adjust light cells based on where the light is placed."""
	
	var tiles_to_erase = []
	var n = $Light/ShapeCast2D.get_collision_count()
	print(n)
	for i in range(n):
		#var collision_tile: Vector2i = $Light.local_to_map(
			#to_local(
				#$Light/ShapeCast2D.get_collision_point(i)
			#) / $Light.scale.x
		#)
		var collision_pisition: Vector2 = $Light/ShapeCast2D.get_collision_point(i)
		var collision_tile: Vector2i = get_local_cell_coords(collision_pisition)
		print(collision_tile)
		tiles_to_erase.append(collision_tile)
		if self.occlusion.has(collision_tile):
			var blocked_tiles = self.occlusion[collision_tile]
			for tile in blocked_tiles:
				if not tiles_to_erase.has(tile):
					tiles_to_erase.append(tile)
	
	# erase tiles
	print("erase: ", tiles_to_erase)
	for tile in tiles_to_erase:
		$Light.erase_cell(tile)


func calculate_covered_area() -> float:
	"""Calculate how many tiles are still present for area calculation."""
	
	full_light_tiles = $Light.get_used_cells_by_id(0, Vector2i(5, 7), 0).size()
	left_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(9, 7), 0).size()
	right_half_tiles = $Light.get_used_cells_by_id(0, Vector2i(10, 7), 0).size()
	
	#self.covered_area = full_light_tiles + 0.5 * left_half_tiles + 0.5 * right_half_tiles
	
	return full_light_tiles + 0.5 * left_half_tiles + 0.5 * right_half_tiles


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
