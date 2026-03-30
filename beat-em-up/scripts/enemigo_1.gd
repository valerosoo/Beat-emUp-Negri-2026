extends CharacterBody2D

enum Estado {PATROL, IDLE, CHASE, ATTACK, RETURN_PATROL}

@export var speed = 120
@export var patrol_distance = 200
@export var wait_time = 2
@export var distancia_para_atacar = 100

var estado = Estado.PATROL
var posicion_inicial
var objetivo_posicion
var timer = 0
var atacando = false

var player

func _ready():
	posicion_inicial = global_position
	objetivo_posicion = posicion_inicial + Vector2(randf_range(-patrol_distance,patrol_distance), randf_range(-patrol_distance,patrol_distance))

	player = get_tree().get_first_node_in_group("jugador")
	
func _physics_process(delta):

	match estado:
		Estado.PATROL:
			patrullar(delta)
		
		Estado.IDLE:
			idle(delta)
		
		Estado.CHASE:
			perseguir(delta)
		
		Estado.ATTACK:
			atacar()
		
		Estado.RETURN_PATROL:
			volver_a_patrullar(delta)
			
func patrullar(delta):

	var direction = (objetivo_posicion - global_position).normalized()
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	
	velocity = direction * speed
	move_and_slide()

	$AnimatedSprite2D.play("walk")

	if global_position.distance_to(objetivo_posicion) < 5:
		estado = Estado.IDLE
		timer = wait_time
		
func idle(delta):

	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("idle")

	timer -= delta

	if timer <= 0:
		swap_patrol_point()
		estado = Estado.PATROL
		
		
func swap_patrol_point():

	if objetivo_posicion == posicion_inicial:
		objetivo_posicion = posicion_inicial + Vector2(patrol_distance, 0)
	else:
		objetivo_posicion = posicion_inicial

func _on_radar_body_entered(body):
	if body.is_in_group("jugador"):
		estado = Estado.CHASE
		
func perseguir(delta):

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	$AnimatedSprite2D.play("walk")
	
	var distancia = global_position.distance_to(player.global_position)
	
	if distancia < distancia_para_atacar:
		estado = Estado.ATTACK

func atacar():

	velocity = Vector2.ZERO

	if !atacando:
		atacando = true
		$AnimatedSprite2D.play("combo")

func _on_animated_sprite_2d_animation_finished():

	if $AnimatedSprite2D.animation == "combo":
		atacando = false
		
		var distancia = global_position.distance_to(player.global_position)

		if distancia < distancia_para_atacar:
			estado = Estado.ATTACK
		elif distancia < 200:
			estado = Estado.CHASE
		else:
			estado = Estado.RETURN_PATROL
			
func volver_a_patrullar(delta):

	var direction = (posicion_inicial - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	$AnimatedSprite2D.play("walk")

	if global_position.distance_to(posicion_inicial) < 5:
		estado = Estado.PATROL

func _on_radar_body_exited(body):
	if body.is_in_group("jugador"):
		estado = Estado.RETURN_PATROL
