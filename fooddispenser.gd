extends StaticBody2D


@export var food = preload("res://food.tscn")
@export var food_cooldown : float
@export var food_limit : int
@export var food_spawn_range : float


var ini_food_cooldown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ini_food_cooldown = food_cooldown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	food_cooldown -= delta
	if food_cooldown < 0 and Global.food_amount <= food_limit:
		food_cooldown = ini_food_cooldown
		_spawn()


func _spawn():
	Global.food_amount += 1
	var instance = food.instantiate()
	instance.global_position = global_position + Vector2(randf_range(-food_spawn_range, food_spawn_range), randf_range(-food_spawn_range, food_spawn_range))
	get_parent().add_child(instance)
