extends StaticBody2D

@export var decay: float
@export var decay_rate: float = 1
@export var strength_limit: float
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

@onready var debug = $Label
@onready var debug2 = $Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	ini_decay_rate = decay_rate
	ini_refresh_rate = refresh_rate
	home = get_parent().get_parent().get_parent().get_node("home").global_position
	if home:
		distance_to_home = global_position.distance_to(home)
	food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
	distance_to_food = global_position.distance_to(food)
	if enable_debug:
		debug.text = str(distance_to_home)
		debug2.text = str(distance_to_food)
	elif !enable_debug:
		debug.hide()
		debug2.hide()
	var point = get_parent().pointer_position
	pointer_pos = point.global_position
	print(pointer_pos)
	ini_position_refresh = position_refresh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	decay_rate -= delta
	if decay_rate < 0:
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
		home = get_parent().get_parent().get_parent().get_node("home").global_position
		distance_to_home = global_position.distance_to(home)
		food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
		distance_to_food = global_position.distance_to(food)
		position_refresh = ini_position_refresh
	
