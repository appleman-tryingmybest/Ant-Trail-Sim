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

func _ready():
	stylebox = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)


func _check():
	match info.pheroType:
		0: my_color = Color(1, 1, 1)
		1: my_color = Color(0, 1, 0)
	if info.pheroType == 0:
		alpha = remap(info.strength, 0.1, info.strength_limit, 0.05, 1)
	stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)
	add_theme_stylebox_override("panel", stylebox)
