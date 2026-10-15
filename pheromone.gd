extends StaticBody2D

@export var decay: float
@export var decay_rate: float = 1
@export var initial_strength: float
@export var terrible_debug = false
@export var lifetime_limit: float

var ownerant: Node2D
var ini_decay_rate: float
var strength: float
var distance_to_home: float
var distance_to_food: float
var lifetime: float

@onready var color = $White
@onready var text = $debug
@onready var detectionArea = $Area2D

var pheroType: int = 0
var decayincrease

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ini_decay_rate = decay_rate
	decayincrease = decay * 2
	strength = initial_strength
	var home = get_parent().get_node("home").global_position
	if home:
		distance_to_home = global_position.distance_to(home)
	if !terrible_debug:
		text.queue_free()
	match pheroType:
		0: color.modulate = Color(1, 1, 1)
		1: color.modulate = Color(0, 1, 0)
	if pheroType == 1:
		var food = get_parent().get_node("fooddispenser").global_position
		distance_to_food = global_position.distance_to(food)
		decay_rate += 1
	Global.phero_amount += 1
	print(Global.phero_amount)
	detectionArea.pheroType = pheroType

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	decay_rate -= delta
	if decay_rate < 0:
		strength -= decay
		decay_rate = ini_decay_rate
	

	color.modulate.a = remap(strength, initial_strength, 0, 1.0, 0.0)
	if color.modulate.a <= 0.05:
		Global.phero_amount -= 1
		queue_free()
	
	if terrible_debug:
		text.text = "strength: " + str(strength) + " distance to home: " + str(distance_to_home)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body.pheroType == 0:
		body.queue_free()
		Global.phero_amount -= 1
	elif body.pheroType == 1 and self.pheroType == 0 or body.strength > self.strength:
		queue_free()
		Global.phero_amount -= 1
