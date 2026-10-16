extends StaticBody2D

@export var decay: float
@export var decay_rate: float = 1
@export var strength_limit: float
@export var refresh_rate: float

var ownerant: Node2D
var ini_decay_rate: float
var strength: float
var distance_to_home: float
var distance_to_food: float
var pheroType: int = 0
var decayincrease
var home
var ini_refresh_rate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	ini_decay_rate = decay_rate
	ini_refresh_rate = refresh_rate
	decayincrease = decay * 2
	home = get_parent().get_parent().get_parent().get_node("home").global_position
	if home:
		distance_to_home = global_position.distance_to(home)
	if pheroType == 1:
		var food = get_parent().get_parent().get_parent().get_node("fooddispenser").global_position
		distance_to_food = global_position.distance_to(food)
		decay_rate += 1

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
