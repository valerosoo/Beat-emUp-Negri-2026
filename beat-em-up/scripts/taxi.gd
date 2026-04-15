extends Node2D

@onready var puerta = $Puerta

func abrir():
	puerta.play("open")
	
func cerrar():
	puerta.play("close")

func aparecer_jugador_adentro():
	$Sprite2D.visible = true
