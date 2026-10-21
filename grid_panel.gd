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
@onready var detect_col = $wall_detect/CollisionShape2D
@onready var stylebox = get_theme_stylebox("panel")
@onready var pointer_position = $point

func _ready():
	stylebox = get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)
	cell_height = get_parent().cell_height
	cell_width = get_parent().cell_width
	_resizeCol()
	_check()

func _resizeCol():
	if !col or !col.shape:
		print("weirdly not work")
		return
	col.shape.size = Vector2(cell_width, cell_height)
	detect_col.shape.size = Vector2(cell_width, cell_height)
	pointer_position.position = Vector2(cell_width/2, cell_height/2)

func _check():
	if info.strength <= -99:
		stylebox.bg_color = Color(0, 0, 0, 0.2)
		return
	elif (info.strength >= info.strength_limit and info.pheroType == 0) or (info.strength >= info.food_strength_limit and info.pheroType == 1):
		return
	else:
		match info.pheroType:
			0: my_color = Color(1, 1, 1)
			1: my_color = Color(0, 1, 0)
		alpha = remap(info.strength, 0.1, info.strength_limit, 0.05, 1)
		stylebox.bg_color = Color(my_color.r, my_color.g, my_color.b, alpha)
	add_theme_stylebox_override("panel", stylebox)


func _on_wall_detect_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
