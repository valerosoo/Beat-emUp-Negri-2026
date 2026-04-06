extends CharacterBody2D
class_name Enemigo

enum Estado {IDLE, CHASE, ATTACK, DEATH}

@onready var attack_area = get_node("AttackArea")

@export var escena_original : PackedScene
@export var speed = 120
@export var distancia_para_atacar = 140
@export var nombre_animacion_atacar = "combo"
@export var frames_de_ataque = [1,5,15]
@export var dano = [5, 15, 20]
@export var vida = 50

var estado = Estado.IDLE
var atacando = false
var attack_offset
var player
var player_hurtBox
var distancia
var puede_hacer_dano = false

func _ready():
	attack_offset = attack_area.position.x
	player = get_tree().get_first_node_in_group("jugador")
	player_hurtBox = player.get_node("Pivote/HurtBox")
	
func _physics_process(delta):
	
	if estado == Estado.DEATH:
		return 
	
	distancia = global_position.distance_to(player_hurtBox.global_position)
	
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
	
	if distancia < distancia_para_atacar:
		estado = Estado.ATTACK

func atacar():
	velocity = Vector2.ZERO
	
	
	if distancia > distancia_para_atacar:
		atacando = false
		estado = Estado.CHASE
		return
	
	if !atacando:
		atacando = true
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play(nombre_animacion_atacar)

func _on_animated_sprite_2d_animation_finished():
	
	if $AnimatedSprite2D.animation == nombre_animacion_atacar:
		atacando = false
		
		if distancia < distancia_para_atacar:
			estado = Estado.ATTACK
			
	elif $AnimatedSprite2D.animation == "death":
		queue_free()
		
func girar_sprite():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = attack_offset
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = -attack_offset
		
func _on_radar_body_exited(body: Node2D) -> void:
	if estado == Estado.DEATH:
		return
	if body.is_in_group("jugador"):
		estado = Estado.IDLE

func _on_animated_sprite_2d_frame_changed() -> void:
	puede_hacer_dano = false
	if atacando and $AnimatedSprite2D.frame in frames_de_ataque:
		if puede_hacer_dano:
			return
			
		var frame = $AnimatedSprite2D.frame
		var index = frames_de_ataque.find(frame)
		var dano_golpe = dano[index]
		puede_hacer_dano = true
		var areas = attack_area.get_overlapping_areas()
		
		for area in areas:
			print("Detecté:", area.name)
			if area.is_in_group("HurtBox") and area.get_parent().get_parent().is_in_group("jugador"):
				player.restar_vida(dano_golpe, self)

func restar_vida(dano):
	vida -= dano
	print("Me pegaron")
	verificar_muerte()
	
func sumar_vida(suma):
	vida += suma
	
func verificar_muerte():
	if vida <= 0:
		print("enemigo murio")
		estado = Estado.DEATH
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("death")
