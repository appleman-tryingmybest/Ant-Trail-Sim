@tool
extends GridContainer

@export var width: int: #def 27
	set(value):
		width = value
		_remove_grid()
		_create_grid()

@export var height: int: #def 14
	set(value):
		height = value
		_remove_grid()
		_create_grid()

@export var cell_width: int: #def 75
	set(value):
		cell_width = value
		_remove_grid()
		_create_grid()

@export var cell_height: int: #def 82
	set(value):
		cell_height = value
		_remove_grid()
		_create_grid()


var grid_cell = preload("res://grid_panel.tscn")
var border_size = 4
# Lookup table for block_at. Filled on first use, after the container has laid out its cells.
var blocks: Array = []
var cell_origin: Vector2
var cell_pitch: Vector2

func _ready() -> void:
	# The setter builds the grid once with the final height.
	cell_height += 1

func _create_grid():
	# Exported values are set before the node enters the tree. Building then would be thrown away.
	if !is_inside_tree():
		return
	columns = width
	for i in width * height:
		var grid_cell_node = grid_cell.instantiate()
		grid_cell_node.custom_minimum_size = Vector2(cell_width, cell_height)
		add_child(grid_cell_node)

func _remove_grid():
	blocks.clear()
	for node in get_children():
		node.queue_free()

# Returns the pheromone block under a world position, or null outside the grid.
func block_at(pos: Vector2) -> Node:
	if blocks.is_empty():
		_cache_blocks()
		if blocks.is_empty():
			return null
	var col = int(floor((pos.x - cell_origin.x) / cell_pitch.x))
	var row = int(floor((pos.y - cell_origin.y) / cell_pitch.y))
	if col < 0 or row < 0 or col >= width or row >= height:
		return null
	return blocks[row * width + col]

func _cache_blocks():
	var cells = get_children()
	cell_origin = cells[0].global_position
	cell_pitch = Vector2(cells[1].global_position.x - cell_origin.x, cells[width].global_position.y - cell_origin.y)
	if cell_pitch.x <= 0 or cell_pitch.y <= 0:
		push_error("grid cells are not laid out yet")
		return
	for cell in cells:
		blocks.append(cell.get_node("pheromone_block"))

