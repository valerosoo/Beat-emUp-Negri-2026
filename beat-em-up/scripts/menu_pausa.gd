extends Node2D

@onready var opciones = $Opciones2
@onready var control = $Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opciones.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continuar_pressed() -> void:
	GameManager.sonido_menu_select()
	get_tree().paused = false
	get_tree().get_first_node_in_group("jugador").set_physics_process(true)
	get_parent().get_parent().get_node("CanvasLayer/Barra_vida").visible = true
	visible = false

func _on_menu_pressed() -> void:
	GameManager.sonido_menu_select()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_opciones_pressed() -> void:
	GameManager.sonido_menu_select()
	GameManager.viene_del_menu = false
	get_parent().get_parent().get_node("CanvasLayer/Barra_vida").visible = false
	control.visible = false
	opciones.visible = true
