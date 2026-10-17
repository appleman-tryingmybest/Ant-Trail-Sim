extends Node

@export var total_phero_amount = 1000

var food_amount = 0
var phero_amount = 0

# Central timers for all pheromone blocks. Intervals are copied from the first registered block.
var pheromone_blocks: Array = []
var decay_interval: float
var refresh_interval: float
var position_interval: float
var decay_timer: float
var refresh_timer: float
var position_timer: float

func register_block(block: Node) -> void:
	if pheromone_blocks.is_empty():
		decay_interval = block.decay_rate
		refresh_interval = block.refresh_rate
		position_interval = block.position_refresh
		decay_timer = decay_interval
		refresh_timer = refresh_interval
		position_timer = position_interval
	pheromone_blocks.append(block)

func unregister_block(block: Node) -> void:
	pheromone_blocks.erase(block)

func _process(delta: float) -> void:
	if pheromone_blocks.is_empty():
		return
	decay_timer -= delta
	if decay_timer < 0:
		decay_timer = decay_interval
		for block in pheromone_blocks:
			block.decay_tick()
	refresh_timer -= delta
	if refresh_timer < 0:
		refresh_timer = refresh_interval
		for block in pheromone_blocks:
			block.refresh_tick()
	position_timer -= delta
	if position_timer < 0:
		position_timer = position_interval
		for block in pheromone_blocks:
			block.position_tick()
