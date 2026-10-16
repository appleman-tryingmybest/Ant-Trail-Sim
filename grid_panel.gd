extends PanelContainer

@export var cell_height: int:
	set(value):
		cell_height = value

@export var cell_width: int:
	set(value):
		cell_width = value

var alpha: float = 0.1
var my_color = Color(1, 1, 1)

@onready var info  = $pheromone_block
@onready var col = $pheromone_block/CollisionShape2D
@onready var stylebox = get_theme_stylebox("panel")
@onready var pointer_position = $point

func _ready():
	stylebox = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)
	col.shape = col.shape.duplicate()
	await get_tree().create_timer(1).timeout
	cell_height = get_parent().cell_height
	cell_width = get_parent().cell_width
	_resizeCol()

func _resizeCol():
	if !col or !col.shape:
		return
	col.shape.size = Vector2(cell_width, cell_height)
	pointer_position.position = Vector2(cell_width/2, cell_height/2)



func _check():
	match info.pheroType:
		0: my_color = Color(1, 1, 1)
		1: my_color = Color(0, 1, 0)
	alpha = remap(info.strength, 0.1, info.strength_limit, 0.05, 1)
	stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)
	add_theme_stylebox_override("panel", stylebox)
