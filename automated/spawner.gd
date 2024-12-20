extends Node2D

enum Parts {BASE, LID}
@export var speed = 30  # objects per minute

var is_spawning: bool = false

@onready var timer = $Timer
@onready var item_hold = $ItemHold
@onready var belt_detector = $BeltDetector


func _ready() -> void:
	timer.wait_time = 60.0 / speed
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	await get_tree().create_timer(1).timeout
	spawn_item()


func _on_timer_timeout():
	spawn_item()


func spawn_item():
	if item_hold.get_child_count() == 0:
		var item = preload("res://automated/belt_item.tscn").instantiate()
		var belt = get_next_belt()
		if belt as Belt != null:
			item_hold.add_child(item)
			belt.receive_item(item)


func get_next_belt():
	var areas = belt_detector.get_overlapping_areas()
	for area in areas:
		if area is Belt:
			if area.can_receive_item():
				#if not area.has_item_held():
				return area
