extends Node2D
class_name Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.sonido_menu_start()
	ManejadorGuardado.cargar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_jugar_pressed() -> void:
	GameManager.sonido_menu_select()
	get_tree().change_scene_to_file("res://scenes/elegir_nivel.tscn")

func _on_opciones_pressed() -> void:
	GameManager.viene_del_menu = true
	GameManager.sonido_menu_select()
	get_tree().change_scene_to_file("res://scenes/opciones.tscn")

func _on_salir_pressed() -> void:
	GameManager.sonido_menu_select()
	get_tree().quit()
