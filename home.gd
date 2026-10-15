extends Node2D

@export var ant = preload("res://ant.tscn")
@export var total_ant: int
@export var spawn_cooldown: float

var ant_amount:= 0
var def_spawn_cooldown : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	def_spawn_cooldown = spawn_cooldown
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ant_amount < total_ant:
		spawn_cooldown -= delta
		if spawn_cooldown < 0:
			_spawn()
			spawn_cooldown = def_spawn_cooldown
	else:
		pass

func _spawn():
	ant_amount += 1
	var instance = ant.instantiate()
	instance.global_position = global_position
	get_parent().add_child(instance)

func _on_button_button_down() -> void:
	_spawn()
