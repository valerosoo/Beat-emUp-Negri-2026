extends Node2D

@onready var puerta = $Puerta

func abrir():
	puerta.play("open")
	
func cerrar():
	puerta.play("close")
