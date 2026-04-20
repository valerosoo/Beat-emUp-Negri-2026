extends Node2D

@onready var puerta = $Puerta

var girando = false

func _physics_process(delta: float) -> void:
	if girando:
		$RuedaAtras.rotation += 5 * delta
		$RuedaDelante.rotation += 5 * delta
	
func abrir():
	puerta.play("open")
	
func cerrar():
	puerta.play("close")

func aparecer_jugador_adentro():
	$Sprite2D.visible = true

func desaparecer_jugador_adentro():
	$Sprite2D.visible = false

func iniciar_ruedas():
	girando = true
	
func parar_ruedas():
	girando = false
