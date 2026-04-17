extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continuar_pressed() -> void:
	get_tree().paused = false
	get_tree().get_first_node_in_group("jugador").set_physics_process(true)
	visible = false


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_opciones_pressed() -> void:
	pass # Replace with function body.
