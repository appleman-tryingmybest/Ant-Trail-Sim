extends Node2D

@export var lifetime: float
var carried = false


func _process(delta: float) -> void:
	if carried:
		lifetime -= delta
		if lifetime < 0:
			queue_free()

func _exit_tree() -> void:
	Global.food_amount -= 1
