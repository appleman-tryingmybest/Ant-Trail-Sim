@tool
extends GridContainer

@export var width = 5:
	set(value):
		width = value
		_remove_grid()
		_create_grid()

@export var height = 5:
	set(value):
		height = value
		_remove_grid()
		_create_grid()

@export var cell_width = 100:
	set(value):
		cell_width = value
		_remove_grid()
		_create_grid()

@export var cell_height = 100:
	set(value):
		cell_height = value
		_remove_grid()
		_create_grid()


var grid_cell = preload("res://grid_panel.tscn")
var border_size = 4

func _ready() -> void:
	_create_grid()

func _create_grid():
	columns = width
	
	for i in width * height:
		var grid_cell_node = grid_cell.instantiate()
		grid_cell_node.custom_minimum_size = Vector2(cell_width, cell_height)
		add_child(grid_cell_node.duplicate())

func _remove_grid():
	for node in get_children():
		node.queue_free()
