extends Area2D

@export var duracion : int = 5

var vida_a_curar: float = 0.0

func inicializar(vida_maxima_enemigo: int):
	vida_a_curar = vida_maxima_enemigo * 0.15
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(duracion).timeout
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		var nueva_vida = min(body.vida + vida_a_curar, body.vida_maxima)
		body.vida = nueva_vida
		body.barra_vida.value = nueva_vida
		queue_free()
		
func idle():
	$AnimatedSprite2D.play("idle")

func desvanece():
	$AnimatedSprite2D.play("disapearing")
