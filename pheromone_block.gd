extends StaticBody2D

@export var decay: float
@export var decay_rate: float = 1
@export var strength_limit: float
@export var food_strength_limit: float
@export var refresh_rate: float
@export var enable_debug = false
@export var position_refresh: float

var ownerant: Node2D
var ini_decay_rate: float
var strength: float
var distance_to_home: float
var distance_to_food: float
var pheroType: int = 0
var home
var food
var ini_refresh_rate
var pointer_pos: Vector2
var ini_position_refresh
var is_blocked = false

@onready var debug = $Label
@onready var debug2 = $Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ini_decay_rate = decay_rate
	ini_refresh_rate = refresh_rate
	if enable_debug:
		debug.text = str(distance_to_home)
		debug2.text = str(distance_to_food)
	elif !enable_debug:
		debug.hide()
		debug2.hide()
	await get_tree().process_frame
	var point = get_parent().pointer_position
	pointer_pos = point.global_position
	print(pointer_pos)
	ini_position_refresh = position_refresh
	_recheck_position_of_targets()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_blocked:
		strength = -99
		return
	else:
		pass
	if strength >= strength_limit and pheroType == 0:
		strength = strength_limit
	elif strength >= food_strength_limit and pheroType == 1:
		strength = food_strength_limit
	decay_rate -= delta
	if decay_rate < 0:
		if strength <= -5:
			strength = -5
		else:
			strength -= decay
		decay_rate = ini_decay_rate
		if pheroType == 1 and strength < 0:
			pheroType = 0

	refresh_rate -= delta
	if refresh_rate < 0:
		var look = get_parent()._check()
		refresh_rate = ini_refresh_rate
	
	position_refresh -= delta
	if position_refresh < 0:
		position_refresh = ini_position_refresh
		_recheck_position_of_targets()


func _recheck_position_of_targets():
	home = get_parent().get_parent().get_parent().get_node("home").global_position
	distance_to_home = global_position.distance_to(home)
	food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
	distance_to_food = global_position.distance_to(food)


func _on_wall_detect_body_entered(body: Node2D) -> void:
	is_blocked = true
