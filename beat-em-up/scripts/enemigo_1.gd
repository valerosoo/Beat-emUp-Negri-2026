extends CharacterBody2D
class_name Enemigo1

enum Estado {IDLE, CHASE, ATTACK}

@onready var attack_area = get_node("AttackArea")

@export var speed = 120
@export var wait_time = 2
@export var distancia_para_atacar = 100

var estado = Estado.IDLE
var posicion_inicial
var objetivo_posicion
var timer = 0
var atacando = false
var attack_offset
var player

func _ready():
	posicion_inicial = global_position
	attack_offset = attack_area.position.x
	player = get_tree().get_first_node_in_group("jugador")
	
func _physics_process(delta):
	girar_sprite()
	
	match estado:
		
		Estado.IDLE:
			idle(delta)
		
		Estado.CHASE:
			perseguir(delta)
		
		Estado.ATTACK:
			atacar()
			
func idle(delta):
	
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("idle")
	
	
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
			
	
func girar_sprite():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = attack_offset
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = -attack_offset
