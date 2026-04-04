extends Node2D
class_name Menu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ManejadorGuardado.cargar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/elegir_nivel.tscn")


func _on_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit() # Replace with function body.
