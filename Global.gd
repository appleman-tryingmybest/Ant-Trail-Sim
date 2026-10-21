extends Node

@export var decay_rate = 1.0
@export var refresh_rate = 0.5
@export var position_refresh = 60.0

signal decay()
signal refresh()
signal checkPos()

var food_amount = 0
var phero_amount = 0

var ini_DR
var ini_RR
var ini_PR

func _ready() -> void:
	ini_DR = decay_rate
	ini_RR = refresh_rate
	ini_PR = position_refresh

func _process(delta: float) -> void:
	decay_rate -= delta
	if decay_rate < 0:
		decay.emit()
		decay_rate = ini_DR
	refresh_rate -= delta
	if refresh_rate < 0:
		refresh.emit()
		refresh_rate = ini_RR
	position_refresh -= delta
	if position_refresh < 0:
		await get_tree().process_frame
		print("check that shi cuh")
		checkPos.emit()
		position_refresh = ini_PR
	
