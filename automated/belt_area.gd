extends Node2D

@onready var tilemap: TileMapLayer = $Belts

var is_drawing: bool = false
var is_erasing: bool = false
var last_tile_position: Vector2i
var last_direction: Vector2i
var tile_sequence: Array

var atlas_mapping: Dictionary = {
	"right": Vector2i(2, 0),
	"left": Vector2i(2, 2),
	"up": Vector2i.DOWN,
	"down": Vector2i(4, 1),
	"up_right": Vector2i(0, 0),
	"up_left": Vector2i(4, 3),
	"down_right": Vector2i(0, 5),
	"down_left": Vector2i(4, 2),
	"right_up": Vector2i(4, 5),
	"right_down": Vector2i(4, 0),
	"left_up": Vector2i(0, 2),
	"left_down": Vector2i(0, 3),
}


func _ready():
	tilemap.clear()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start drawing
			tile_sequence = []
			is_drawing = true
			last_direction = Vector2i.ZERO  # start
			last_tile_position = tilemap.local_to_map(event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Stop drawing
			is_drawing = false
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			is_erasing = true
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			is_erasing = false


func _process(delta):
	if is_drawing:
		var mouse_position = tilemap.local_to_map(get_local_mouse_position())
		if mouse_position != last_tile_position:
			# Calculate the direction from the last tile to the current mouse position
			var current_direction = mouse_position - last_tile_position
			if last_direction != Vector2i.ZERO and current_direction != last_direction:
				# Place a corner if direction changes
				place_tile(last_tile_position, current_direction, last_direction)
				tile_sequence.append([mouse_position, current_direction, last_direction])
			# Place the next tile
			place_tile(mouse_position, current_direction)
			tile_sequence.append([mouse_position, current_direction, last_direction])
			
			# hack to draw the first tile
			#print(tile_sequence)
			if tile_sequence.size() == 3:  # ie from 0->1, 1->,
				if tile_sequence[0][2] == Vector2i.ZERO:  # if the first tile is not drawn
					place_tile(tile_sequence[0][0], tile_sequence[1][1])  # draw at first tile postion with direction of 2nd tile
			
			last_tile_position = mouse_position
			last_direction = current_direction
	
	elif is_erasing:
		var mouse_position = tilemap.local_to_map(get_local_mouse_position())
		tilemap.erase_cell(mouse_position)


func place_tile(position: Vector2i, current_direction: Vector2i, previous_direction: Vector2i = Vector2i.ZERO):
	# Determine the tile ID based on direction or corner
	var tile_id: Vector2i
	if previous_direction == Vector2i.ZERO:
		tile_id = get_tile_id_for_direction(current_direction)  # Straight tiles
	else:
		tile_id = get_tile_id_for_corner(previous_direction, current_direction)  # Corners
	tilemap.set_cell(position, 0, tile_id, 0)


func get_tile_id_for_direction(direction: Vector2i) -> Vector2i:
	# Determine tile based on direction
	if direction == Vector2i.RIGHT:
		return atlas_mapping["right"]  # Right
	elif direction == Vector2i.LEFT:
		return atlas_mapping["left"]  # Left
	elif direction == Vector2i.DOWN:
		return atlas_mapping["down"]  # Down
	elif direction == Vector2i.UP:
		return atlas_mapping["up"]  # Up
	else:
		return Vector2i(-1, -1)  # Default or no tile


func get_tile_id_for_corner(previous: Vector2i, current: Vector2i) -> Vector2i:
	# Determine the tile ID for corners based on previous and current direction
	if previous == Vector2i.RIGHT and current == Vector2i.UP:  # Right to Up
		return atlas_mapping["right_up"] # Top-right corner
	elif previous == Vector2i.RIGHT and current == Vector2i.DOWN:  # Right to Down
		return atlas_mapping["right_down"]  # Bottom-right corner
	elif previous == Vector2i.LEFT and current == Vector2i.UP:  # Left to Up
		return atlas_mapping["left_up"]  # Top-left corner
	elif previous == Vector2i.LEFT and current == Vector2i.DOWN:  # Left to Down
		return atlas_mapping["left_down"]  # Bottom-left corner
	elif previous == Vector2i.DOWN and current == Vector2i.RIGHT:  # Down to Right
		return atlas_mapping["down_right"]  # Bottom-right corner
	elif previous == Vector2i.DOWN and current == Vector2i.LEFT:  # Down to Left
		return atlas_mapping["down_left"]  # Bottom-left corner
	elif previous == Vector2i.UP and current == Vector2i.RIGHT:  # Up to Right
		return atlas_mapping["up_right"]  # Top-right corner
	elif previous == Vector2i.UP and current == Vector2i.LEFT:  # Up to Left
		return atlas_mapping["up_left"]  # Top-left corner
	else:
		return Vector2i(-1, -1)  # Default tile or no tile
