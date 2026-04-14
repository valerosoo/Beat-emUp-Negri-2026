extends Button
class_name  Tarjeta

@onready var hover = $ColorRect
@onready var label = $Label
@onready var imagen = $TextureRect

@export var nivel = 1
@export var imagen_nivel : Texture2D

var bloqueado = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Nivel " + str(nivel)
	imagen.texture = imagen_nivel
	$Candado.visible = false
	
	if nivel > ManejadorGuardado.niveles.niveles_desbloqueados:
		disabled = true
		bloqueado = true
		$Candado.visible = true
		imagen.modulate = Color(0.7,0.7,0.7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered():
	imagen.modulate = Color(0.7,0.7,0.7)

func _on_mouse_exited():
	if !bloqueado:
		imagen.modulate = Color(1,1,1)


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/nivel_1.tscn")

func _on_tarjeta_nivel_2_pressed() -> void:
	pass # Replace with function body.
