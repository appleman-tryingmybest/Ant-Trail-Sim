extends StaticBody2D

@export var decay: float
@export var strength_limit: float
@export var food_strength_limit: float
@export var enable_debug = false
@export var position_refresh: float

var strength: float
var distance_to_home: float
var distance_to_food: float
var pheroType: int = 0
var home
var food
var pointer_pos: Vector2
var ini_position_refresh
var is_blocked = false
var average_velocity = Vector2.ZERO
var ant1 = null
var ant2 = null
# Points the way home on this square. Opposite direction points to food.
var home_flow = Vector2.ZERO

@onready var debug = $Label
@onready var debug2 = $Label2
@onready var debug3 = $Label3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.decay.connect(_decay_check)
	Global.refresh.connect(_refresh_check)
	Global.checkPos.connect(_recheck_position_of_targets)
	if !enable_debug:
		debug.queue_free()
		debug2.queue_free()
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

func _decay_check():
		if strength <= -5:
			strength = -5
		else:
			strength -= decay
		if pheroType == 1 and strength < 0:
			pheroType = 0
		home_flow *= 0.95

func _refresh_check():
	var look = get_parent()._check()

func _recheck_position_of_targets():
	home = get_parent().get_parent().get_parent().get_node("home").global_position
	distance_to_home = global_position.distance_to(home)
	food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
	distance_to_food = global_position.distance_to(food)
	if enable_debug:
		debug.text = str(distance_to_home)
		debug2.text = str(distance_to_food)

func _average_velo(body: Node2D):

	if !ant1:
		ant1 = body
	elif ant1 and !ant2:
		ant2 = body
	if ant1 and ant2:
		var total_x = (ant1 as CharacterBody2D).velocity.x + (ant2 as CharacterBody2D).velocity.x
		var total_y = (ant1 as CharacterBody2D).velocity.y + (ant2 as CharacterBody2D).velocity.y
		average_velocity = Vector2(total_x/2, total_y/2)
		debug3.text = str(average_velocity)
		ant1 = null
		ant2 = null

func _on_wall_detect_body_entered(body: Node2D) -> void:
	if body.collision_layer == 64:
		is_blocked = true
		return
	elif body.collision_layer == 2 and !is_blocked:
		_average_velo(body)
		_record_flow(body)

# Carrying ants head home. Searching ants on a green trail head to food, so their reverse heads home.
func _record_flow(ant: CharacterBody2D):
	var heading = ant.velocity.normalized()
	if ant.takefood:
		home_flow = home_flow.lerp(heading, 0.3)
	elif pheroType == 1:
		home_flow = home_flow.lerp(-heading, 0.3)
		
