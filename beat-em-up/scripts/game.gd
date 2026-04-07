extends Node2D
class_name Game

@onready var gameover = $GameOver
var jugador

func _ready() -> void:
	gameover.visible = false
	
	jugador = $Jugador
	
func _physics_process(delta: float) -> void:
	pass
	
func mostrar_death_screen():
	gameover.visible = true
