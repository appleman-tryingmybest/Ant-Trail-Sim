extends StaticBody2D

var mouse_pos
var dragged = false

func _physics_process(delta: float) -> void:
	if dragged:
		mouse_pos = get_global_mouse_position()
		global_position = mouse_pos



func _on_button_button_down() -> void:
	dragged = true


func _on_button_button_up() -> void:
	dragged = false
