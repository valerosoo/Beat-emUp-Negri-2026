extends Node2D
class_name Game

@onready var gameover = $CanvasLayer/GameOver
var jugador

func _ready() -> void:
	jugador = $Jugador
	
func _physics_process(delta: float) -> void:
	pass
	
func mostrar_death_screen():
	gameover.visible = true
