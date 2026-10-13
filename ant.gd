extends CharacterBody2D

@export var speed: float
@export var pheronome_cooldown: float = 0.7
@export var rotation_angle: float = 10
@export var rotation_cooldown: float = 2
@export var detection_radius: float = 40

var direction
var def_rotation_cooldown
var target: Node2D
var takefood = false

@onready var detectArea = $FoodDetectionArea/CollisionShape2D

enum STATE{think, wander, goToFood}
var currentstate : STATE = STATE.think

func _ready() -> void:
	detectArea.shape.radius = detection_radius
	def_rotation_cooldown = rotation_cooldown
	randomize()
	print ("my eyes is ", detectArea.shape.radius)

func _physics_process(delta: float) -> void:
	match currentstate:
		STATE.think: _think(target)
		STATE.wander: _wander(delta)
		STATE.goToFood: _targetfood(target)
	
	direction = Vector2.RIGHT.rotated(rotation)
	velocity = speed * direction
	move_and_slide()
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal)
			direction = velocity.normalized()
			rotation = direction.angle()
	if takefood and target:
		target.global_position = global_position

func _think(target: Node2D):
	if !target:
		currentstate = STATE.wander
	else:
		currentstate = STATE.goToFood

func _wander(delta: float):
	rotation_cooldown -= delta
	if rotation_cooldown < 0:
		rotation_degrees += randf_range(-rotation_angle, rotation_angle)
		rotation_cooldown = def_rotation_cooldown

func _targetfood(target: Node2D):
	look_at(target.global_position)

func _on_food_detection_area_body_entered(body: Node2D) -> void:
	if !body.carried and !target:
		print("yummy shit")
		body.carried = true
		target = body
		currentstate = STATE.think
	else:
		print("look away")
		body = null
		pass


func _on_take_food_area_body_entered(body: Node2D) -> void:
	if body == target:
		takefood = true
		currentstate = STATE.wander

 
