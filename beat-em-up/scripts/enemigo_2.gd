extends Enemigo1
class_name Enemigo2

var ataques = ["attack_hair", "attack_hair_2"]

func _ready():
	randomize()
	posicion_inicial = global_position

	player = get_tree().get_first_node_in_group("jugador")

func atacar():
	velocity = Vector2.ZERO
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia > distancia_para_atacar:
		atacando = false
		estado = Estado.CHASE
		return
	
	if !atacando:
		atacando = true
		$AnimatedSprite2D.frame = 0
		var ataque_elegigo = elegir_ataque()
		if ataque_elegigo == ataques[1]:
			$AnimatedSprite2D.play(ataque_elegigo)
		elif ataque_elegigo == ataques[2]:
			$AnimatedSprite2D.play(ataque_elegigo)
		
func elegir_ataque():
	var ataque = ataques.pick_random()
	return ataque

func girar_sprite():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea_Hair2.position.x = 37
		$AttackArea_Hair1.position.x = 37
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea_Hair2.position.x = -37
		$AttackArea_Hair1.position.x = -37
