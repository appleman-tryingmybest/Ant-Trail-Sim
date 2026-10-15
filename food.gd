extends Node2D

var carried = false


func _exit_tree() -> void:
	Global.food_amount -= 1
