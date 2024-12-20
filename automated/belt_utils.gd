extends Node

enum Direction {LEFT, RIGHT, UP, DOWN}

var flow_direction: Dictionary = {
	Direction.LEFT: Direction.RIGHT,  # if item comng from left, belt from direction should be right
	Direction.RIGHT: Direction.LEFT,
	Direction.UP: Direction.DOWN,
	Direction.DOWN: Direction.UP,
}
