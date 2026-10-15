extends PanelContainer

@export var cell_height: int:
	set(value):
		cell_height = value


@export var cell_width: int:
	set(value):
		cell_width = value


@onready var col = $StaticBody2D/CollisionShape2D
