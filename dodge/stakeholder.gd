class_name Stakeholder extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func set_animation(anime_name: String):
	$AnimatedSprite2D.play(anime_name)
