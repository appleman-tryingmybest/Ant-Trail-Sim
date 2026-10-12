extends CharacterBody2D

@export var speed: float
@export var pheronome_cooldown: float = 0.7
@export var rotation_angle: float = 10
@export var rotation_cooldown: float = 2

var direction
var def_rotation_cooldown

func _ready() -> void:
	def_rotation_cooldown = rotation_cooldown
	randomize()

func _physics_process(delta: float) -> void:
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
	
	_rotate(delta)

func _rotate(delta: float):
	rotation_cooldown -= delta
	if rotation_cooldown < 0:
		rotation_degrees += randf_range(-rotation_angle, rotation_angle)
		rotation_cooldown = def_rotation_cooldown
