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
	if Engine.is_editor_hint():
		return
	# Connected after the blocks, so this runs after their straight-line distances and replaces them
	Global.checkPos.connect(_update_path_distances)
	# Wait for blocks to detect walls, then for their first straight-line distances
	for i in 3:
		await get_tree().physics_frame
	await get_tree().process_frame
	_update_path_distances()

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

# Walking distance around walls from every block to home and to food.
func _update_path_distances():
	if blocks.is_empty():
		_cache_blocks()
		if blocks.is_empty():
			return
	var scene = get_parent()
	var to_home = _path_costs(scene.get_node("home").global_position)
	var to_food = _path_costs(scene.get_node("fooddispenser").global_position)
	for i in blocks.size():
		blocks[i].distance_to_home = to_home[i]
		blocks[i].distance_to_food = to_food[i]

# Dijkstra over the cells, 8 directions. Blocked cells get a distance but paths do not continue through them.
func _path_costs(target: Vector2) -> Array:
	var costs = []
	costs.resize(blocks.size())
	costs.fill(INF)
	var col = clampi(int(floor((target.x - cell_origin.x) / cell_pitch.x)), 0, width - 1)
	var row = clampi(int(floor((target.y - cell_origin.y) / cell_pitch.y)), 0, height - 1)
	var start = row * width + col
	costs[start] = 0.0
	var open = [start]
	var diagonal = cell_pitch.length()
	while !open.is_empty():
		var best = 0
		for i in open.size():
			if costs[open[i]] < costs[open[best]]:
				best = i
		var current = open[best]
		open.remove_at(best)
		if blocks[current].is_blocked and current != start:
			continue
		var r = current / width
		var c = current % width
		for dr in [-1, 0, 1]:
			for dc in [-1, 0, 1]:
				if dr == 0 and dc == 0:
					continue
				var nr = r + dr
				var nc = c + dc
				if nr < 0 or nc < 0 or nr >= height or nc >= width:
					continue
				var next = nr * width + nc
				var step = diagonal if dr != 0 and dc != 0 else (cell_pitch.x if dc != 0 else cell_pitch.y)
				if costs[current] + step < costs[next]:
					if costs[next] == INF:
						open.append(next)
					costs[next] = costs[current] + step
	# Cells cut off from the target get a large finite value so distance differences stay valid
	for i in costs.size():
		if costs[i] == INF:
			costs[i] = 100000.0
	return costs
