extends CharacterBody2D

@export var speed: float
@export var pheronome_cooldown: float = 0.7
@export var rotation_angle: float = 10
@export var rotation_cooldown: float = 2
@export var detection_radius: float = 40
@export var redundant_pheromone_spawn_chance: int
@export var pheromone_strength_increase : float

var direction
var ini_rotation_cooldown
var target: Node2D
var takefood = false
var foundfood = false # might not be useful anymore
var ini_pheronome_cooldown
var allow_pheromone_drop = true
var target_pheromone: Node2D
var looking_for_phero_type = 0

@onready var detectArea = $FoodDetectionArea/CollisionShape2D
@onready var debug = $Label

enum STATE{think, wander, goToFood, followPhero}
var currentstate : STATE = STATE.think

func _ready() -> void:
	detectArea.shape.radius = detection_radius
	ini_rotation_cooldown = rotation_cooldown
	ini_pheronome_cooldown = pheronome_cooldown
	randomize()

func _physics_process(delta: float) -> void:
	match currentstate:
		STATE.think: _think()
		STATE.wander: _wander(delta)
		STATE.goToFood: _targetfood()
		STATE.followPhero: _go_to_phero()
	
	direction = Vector2.RIGHT.rotated(rotation)
	velocity = speed * direction
	move_and_slide()
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Node2D and collider.collision_layer == 1:
				var normal = collision.get_normal()
				velocity = velocity.bounce(normal)
				direction = velocity.normalized()
				rotation = direction.angle()
	if takefood and target:
		target.global_position = global_position
	debug.text = "Current state is " + str(currentstate)

func _think():
	if target_pheromone != null:
		currentstate = STATE.followPhero
	else:
		if !target and !takefood:
			currentstate = STATE.wander
		elif target and !takefood:
			currentstate = STATE.goToFood

func _wander(delta: float):
	rotation_cooldown -= delta
	if rotation_cooldown < 0:
		rotation_degrees += randf_range(-rotation_angle, rotation_angle)
		rotation_cooldown = ini_rotation_cooldown

func _targetfood():
	if is_instance_valid(target):
		look_at(target.global_position)

func _go_to_phero():
	if is_instance_valid(target_pheromone):
		if global_position.distance_to(target_pheromone.global_position) > 3:
			look_at(target_pheromone.global_position)
		else:
			target_pheromone = null
			currentstate = STATE.wander
	else:
		target_pheromone = null
		currentstate = STATE.wander

func _on_food_detection_area_body_entered(body: Node2D) -> void:
	if !body.carried and !target:
		body.carried = true
		target = body
		currentstate = STATE.think
	else:
		body = null
		pass

func _on_take_food_area_body_entered(body: Node2D) -> void:
	if body == target:
		takefood = true
		currentstate = STATE.wander
		rotation_degrees += 180
		foundfood = true

func _look_for_this_phero_type(): # 0 is white. 1 is green.
	if !takefood:
		looking_for_phero_type = 1 # im trying to find trail to food = go for further distance
	elif takefood:
		looking_for_phero_type = 0 # im trying to go back = go for closer distance

func _on_eye_body_entered(body: Node2D) -> void: # PROBLEM: stupid ass ants wont follow green spaces
	if target and !takefood:                     # to go back home and only use white to go back home
		currentstate = STATE.think               # this causes the ants with food to wander around 
		return                                   # and making the entire space green
	_look_for_this_phero_type()
	if !target_pheromone:
		if body.pheroType == looking_for_phero_type:
			target_pheromone = body
	elif target_pheromone and target_pheromone.strength < body.strength:
		if takefood: 
			if body.distance_to_home < target_pheromone.distance_to_home:# if im going back home i must find closer phero
				target_pheromone = body
		elif looking_for_phero_type == 1 and !takefood: # if im finding food i must find furthest green spot
			if body.distance_to_food < target_pheromone.distance_to_food:
				target_pheromone = body
	currentstate = STATE.think

func _on_send_food_home_area_entered(area: Area2D) -> void:
	if target:
		print("depositing food")
		foundfood = false
		target.queue_free()
		takefood = false
		currentstate = STATE.think
		rotation_degrees += 180
	else:
		pass


func _on_pheromone_check_body_entered(body: Node2D) -> void:
	if body.pheroType == 0:
		body.strength += pheromone_strength_increase
		if takefood:
			body.strength += pheromone_strength_increase * 1.5
			body.pheroType = 1

	elif body.pheroType == 1:
		body.strength += pheromone_strength_increase * 1.2
	
