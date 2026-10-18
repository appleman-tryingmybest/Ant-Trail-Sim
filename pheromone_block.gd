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
# Clamped on write. Replaces the per-frame clamp and blocked reset that ran in _process.
var strength: float:
	set(value):
		if is_blocked:
			strength = -99
		elif pheroType == 0:
			strength = min(value, strength_limit)
		else:
			strength = min(value, food_strength_limit)
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
	Global.register_block(self)
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

func _exit_tree() -> void:
	Global.unregister_block(self)

# Tick functions are called by Global on shared timers.
func decay_tick() -> void:
	if is_blocked:
		return
	if strength <= -5:
		strength = -5
	else:
		strength -= decay
	if pheroType == 1 and strength < 0:
		pheroType = 0

func refresh_tick() -> void:
	if is_blocked:
		return
	get_parent()._check()

func position_tick() -> void:
	if is_blocked:
		return
	_recheck_position_of_targets()


func _recheck_position_of_targets():
	home = get_parent().get_parent().get_parent().get_node("home").global_position
	distance_to_home = global_position.distance_to(home)
	food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
	distance_to_food = global_position.distance_to(food)


func _on_wall_detect_body_entered(body: Node2D) -> void:
	is_blocked = true
	strength = -99
