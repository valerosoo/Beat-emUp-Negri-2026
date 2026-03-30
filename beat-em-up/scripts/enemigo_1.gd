extends CharacterBody2D
class_name Enemigo1

enum Estado {PATROL, IDLE, CHASE, ATTACK, RETURN_PATROL}

@export var speed = 120
@export var patrol_distance = 200
@export var wait_time = 2
@export var distancia_para_atacar = 100

@onready var patrol_area = get_parent().get_node("PatrolArea")
@onready var patrol_shape = patrol_area.get_node("CollisionShape2D")

var estado = Estado.PATROL
var posicion_inicial
var objetivo_posicion
var timer = 0
var atacando = false

var player

func _ready():
	posicion_inicial = global_position
	objetivo_posicion = get_random_patrol_point()

	player = get_tree().get_first_node_in_group("jugador")
	
func _physics_process(delta):

	if estado != Estado.CHASE and estado != Estado.ATTACK:
		if !esta_dentro_del_patrol():
			estado = Estado.RETURN_PATROL

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = 108
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = -108

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
	objetivo_posicion = get_random_patrol_point()

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
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia > distancia_para_atacar:
		atacando = false
		estado = Estado.CHASE
		return
	
	if !atacando:
		atacando = true
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("combo")

func _on_animated_sprite_2d_animation_finished():

	if $AnimatedSprite2D.animation == "combo":
		atacando = false
		
		var distancia = global_position.distance_to(player.global_position)

		if distancia < distancia_para_atacar:
			estado = Estado.ATTACK
		elif distancia < patrol_distance:
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
		if estado != Estado.ATTACK:
			estado = Estado.RETURN_PATROL

func get_random_patrol_point():

	var rect = patrol_shape.shape as RectangleShape2D
	var size = rect.size / 2

	var random_pos = Vector2(
		randf_range(-size.x, size.x),
		randf_range(-size.y, size.y)
	)

	return patrol_area.global_position + random_pos
	
func esta_dentro_del_patrol():

	var rect = patrol_shape.shape as RectangleShape2D
	var size = rect.size / 2
	
	var local_pos = global_position - patrol_area.global_position
	
	return abs(local_pos.x) <= size.x and abs(local_pos.y) <= size.y
