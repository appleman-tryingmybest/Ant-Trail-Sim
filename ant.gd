extends CharacterBody2D

@export var speed: float
@export var pheronome_cooldown: float = 0.7
@export var rotation_angle: float = 10
@export var rotation_cooldown: float = 2
@export var detection_radius: float = 40
@export var redundant_pheromone_spawn_chance: int
@export var pheromone_strength_increase : float
@export var antenna_length: float = 70
@export var antenna_angle: float = 40
@export var sense_cooldown: float = 0.15
@export var turn_speed: float = 5.0
@export var flow_weight: float = 0.5

var direction
var ini_rotation_cooldown
var target: Node2D
var takefood = false
var foundfood = false # might not be useful anymore
var ini_pheronome_cooldown
var allow_pheromone_drop = true
var grid
var sense_timer: float
# World angle picked by the antennae. null means nothing worth following.
var steer_angle = null

@onready var detectArea = $FoodDetectionArea/CollisionShape2D
@onready var ant_color = $Ant
@onready var take_food_area = $TakeFoodArea

enum STATE{think, wander, goToFood, followPhero}
var currentstate : STATE = STATE.think

func _ready() -> void:
	detectArea.shape.radius = detection_radius
	ini_rotation_cooldown = rotation_cooldown
	ini_pheronome_cooldown = pheronome_cooldown
	randomize()
	grid = get_parent().get_node_or_null("GridContainer")
	# Spread sensing over frames so ants do not all sense at once
	sense_timer = randf() * sense_cooldown

func _physics_process(delta: float) -> void:
	sense_timer -= delta
	if sense_timer < 0:
		sense_timer = sense_cooldown
		_sense()
	match currentstate:
		STATE.think: _think()
		STATE.wander: _wander(delta)
		STATE.goToFood: _targetfood()
		STATE.followPhero: _follow_trail(delta)
	
	direction = Vector2.RIGHT.rotated(rotation)
	velocity = speed * direction
	move_and_slide()
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Node2D and (collider.collision_layer == 1 or collider.collision_layer == 64):
				var normal = collision.get_normal()
				velocity = velocity.bounce(normal)
				direction = velocity.normalized()
				rotation = direction.angle()
	if takefood:
		if is_instance_valid(target):
			target.global_position = global_position
		else:
			# Carried food ran out of lifetime
			target = null
			takefood = false
			currentstate = STATE.think
	if !takefood:
		ant_color.modulate = Color(0, 0, 0)
	else:
		ant_color.modulate = Color(0, 1, 0)

func _think():
	if target and !takefood:
		currentstate = STATE.goToFood
	elif steer_angle != null:
		currentstate = STATE.followPhero
	else:
		currentstate = STATE.wander

func _wander(delta: float):
	rotation_cooldown -= delta
	if rotation_cooldown < 0:
		rotation_degrees += randf_range(-rotation_angle, rotation_angle)
		rotation_cooldown = ini_rotation_cooldown

func _targetfood():
	if !is_instance_valid(target):
		target = null
		currentstate = STATE.think
		return
	# body_entered does not fire if the food was already overlapping when claimed
	if take_food_area.overlaps_body(target):
		_pick_up_food()
		return
	look_at(target.global_position)

func _follow_trail(delta: float):
	var diff = wrapf(steer_angle - rotation, -PI, PI)
	rotation += clamp(diff, -turn_speed * delta, turn_speed * delta)

func _on_food_detection_area_body_entered(body: Node2D) -> void:
	if body.collision_layer == 4:
		if !body.carried and !target:
			body.carried = true
			target = body
			currentstate = STATE.think
		else:
			body = null
			pass
	elif body.collision_layer == 16:
		# Only an ant carrying food can deliver it
		if takefood:
			foundfood = false
			if is_instance_valid(target):
				target.queue_free()
			target = null
			takefood = false
			currentstate = STATE.think
			rotation_degrees += 180
		else:
			pass

func _on_take_food_area_body_entered(body: Node2D) -> void:
	if body == target:
		_pick_up_food()

func _pick_up_food():
	takefood = true
	currentstate = STATE.wander
	rotation_degrees += 180
	foundfood = true

# Three antennae (left, front, right) read the grid directly, no physics.
func _sense():
	if !grid or (target and !takefood):
		return
	var here = grid.block_at(global_position)
	if !here:
		return
	var scores = []
	for side in [-1, 0, 1]:
		var angle = rotation + deg_to_rad(antenna_angle) * side
		var block = grid.block_at(global_position + Vector2.RIGHT.rotated(angle) * antenna_length)
		scores.append([_antenna_score(block, here, angle), angle])
	var best = scores[0]
	for s in scores:
		if s[0] > best[0]:
			best = s
	if best[0] <= -1.0:
		# Walls on all three sides
		steer_angle = rotation + PI
	elif scores[1][0] <= -1.0 or best[0] > 0.0 or takefood:
		steer_angle = best[1]
	else:
		steer_angle = null
	currentstate = STATE.think

# Wall or outside the grid is -1. Carrying ants follow the home distance, searching ants follow green trails.
func _antenna_score(block, here, angle: float) -> float:
	if !block or block.is_blocked:
		return -1.0
	var dir = Vector2.RIGHT.rotated(angle)
	if takefood:
		var progress = (here.distance_to_home - block.distance_to_home) / antenna_length
		return progress + 0.5 * max(block.strength, 0.0) / block.strength_limit + flow_weight * block.home_flow.dot(dir)
	if block.pheroType != 1:
		return 0.0
	var progress = (here.distance_to_food - block.distance_to_food) / antenna_length
	return max(block.strength, 0.0) / block.food_strength_limit + progress - flow_weight * block.home_flow.dot(dir)

func _on_pheromone_check_body_entered(body: Node2D) -> void:
	if body.pheroType == 0:
		body.strength += pheromone_strength_increase
		if takefood:
			body.strength += pheromone_strength_increase * 1.3
			body.pheroType = 1

	elif body.pheroType == 1 and takefood:
		body.strength += pheromone_strength_increase 
	
