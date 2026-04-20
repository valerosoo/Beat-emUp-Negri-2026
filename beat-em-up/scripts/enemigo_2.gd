extends CharacterBody2D
class_name Enemigo

enum Estado {IDLE, CHASE, ATTACK, DEATH, STUN}

@onready var attack_area = get_node("AttackArea")
@onready var timer_barra_vida = $Timer

@export var sprite : AnimatedSprite2D
@export var animation_player : AnimationPlayer
@export var escena_original : PackedScene
@export var speed: int = 120
@export var distancia_para_atacar: int = 140
@export var animaciones = {
	"atacar": "shoot", 
	"quieto": "idle", 
	"correr": "run",
	"morir" : "death"
	}
@export var frames_de_ataque : Array = [1,5,15]
@export var dano : Array = [5, 15, 20]
@export var vida : int = 50
@export var duracion_stun: float = 0.7
@export var frames_bloqueo: Array = [0,1,2,4,5,6,14,15,16]
@export var escena_corazon : PackedScene
@export var probabilidad_soltar_corazon : float = 1

var barra_vida
var estado = Estado.IDLE
var atacando = false
var attack_offset
var player
var player_hurtBox
var distancia
var puede_hacer_dano = false
var cayendo = false
var ia_activa = false

func _ready():
	barra_vida = get_node("Barra_vida_enemigo/Control/ProgressBar")
	attack_offset = attack_area.position.x
	player = get_tree().get_first_node_in_group("jugador")
	player_hurtBox = player.get_node("Pivote/HurtBox")
	barra_vida.max_value = vida
	barra_vida.value = vida
	barra_vida.visible = false
	timer_barra_vida.timeout.connect(ocultar_barra)
	await get_tree().create_timer(0.2).timeout
	ia_activa = true
	
func _physics_process(delta):
	if !ia_activa:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("jugador")
		if player == null:
			return
	
	if player_hurtBox == null:
		player_hurtBox = player.get_node("Pivote/HurtBox")
		if player_hurtBox == null:
			return
	
	if estado == Estado.DEATH:
		return 
	
	if player.muerto == true:
		return
	
	if cayendo:
		return
	
	distancia = global_position.distance_to(player_hurtBox.global_position)
	
	girar_sprite()
	
	match estado:
		
		Estado.IDLE:
			idle(delta)
			if distancia > distancia_para_atacar:
				estado = Estado.CHASE
			else:
				estado = Estado.ATTACK
		
		Estado.CHASE:
			perseguir(delta)
			
			if distancia <= distancia_para_atacar:
				estado = Estado.ATTACK
		Estado.ATTACK:
			atacar()
			
			if distancia > distancia_para_atacar:
				atacando = false
				estado = Estado.CHASE
			
func idle(delta):
	velocity = Vector2.ZERO
	sprite.play(animaciones["quieto"])
	
func perseguir(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	sprite.play(animaciones["correr"])
	
	if distancia < distancia_para_atacar:
		estado = Estado.ATTACK

func atacar():
	if player.muerto == true:
		return
	
	velocity = Vector2.ZERO
	
	if distancia > distancia_para_atacar:
		atacando = false
		estado = Estado.CHASE
		return
	
	if !atacando:
		atacando = true
		sprite.frame = 0
		sprite.play(animaciones["atacar"])

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == animaciones["atacar"]:
		atacando = false
		
		if distancia < distancia_para_atacar:
			estado = Estado.ATTACK
			
	elif sprite.animation == "death":
		queue_free()
		
func girar_sprite():
	if attack_offset == null:
		attack_offset = attack_area.position.x
	if player == null:
		return
	var dir = player.global_position.x - global_position.x
	if dir > 0:
		sprite.flip_h = false
		$AttackArea.position.x = attack_offset
	elif dir < 0:
		sprite.flip_h = true
		$AttackArea.position.x = -attack_offset
		
func _on_radar_body_exited(body: Node2D) -> void:
	if estado == Estado.DEATH:
		return
	if body.is_in_group("jugador"):
		estado = Estado.IDLE

func _on_animated_sprite_2d_frame_changed() -> void:
	puede_hacer_dano = false
	
	if estado == Estado.DEATH:
		return
		
	if atacando and sprite.frame in frames_de_ataque:
		if puede_hacer_dano:
			return
		
		var dir = player.global_position.x - global_position.x
		if dir > 0:
			$AttackArea.position.x = attack_offset
		elif dir < 0:
			$AttackArea.position.x = -attack_offset
		
		var frame = sprite.frame
		var index = frames_de_ataque.find(frame)
		var dano_golpe = dano[index]
		puede_hacer_dano = true
		var areas = attack_area.get_overlapping_areas()
		
		for area in areas:

			if area.is_in_group("HurtBox") and area.get_parent().get_parent().is_in_group("jugador"):
				player.restar_vida(dano_golpe, self)

func restar_vida(dano):
	if cayendo:
		return
	vida -= dano
	parpadeo()
	barra_vida.visible = true
	barra_vida.value = vida
	timer_barra_vida.stop()
	timer_barra_vida.start()
	verificar_muerte()
	
func sumar_vida(suma):
	vida += suma
	
func verificar_muerte():
	if vida <= 0:
		estado = Estado.DEATH
		velocity = Vector2.ZERO
		atacando = false
		$CollisionShape2D.disabled = true
		set_collision_layer(0)
		set_collision_mask(0)
		soltar_corazon()
		sprite.play("death")

func stun():
	if estado == Estado.DEATH:
		return
	var estado_anterior = estado
	estado = Estado.STUN
	atacando = false
	sprite.play("hit")
	await get_tree().create_timer(duracion_stun).timeout
	if estado == Estado.DEATH:
		return
	estado = estado_anterior
	
func parpadeo():
	sprite.modulate = Color(0.851, 0.0, 0.0, 1)
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = Color (1,1,1,1)

func ocultar_barra():
	barra_vida.visible = false

func anim_caida():
	if animation_player == null:
		return
	cayendo = true
	animation_player.play("Caer")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Caer":
		cayendo = false
		
func anim_idle():
	sprite.play("bat_idle")
	
func anim_atacar():
	sprite.play("bat_attack")

func anim_run():
	sprite.play("bat_run")

func anim_morir():
	sprite.play("bat_death")

func aplicar_buff(buff):
	vida *= buff
	speed *= buff
	for i in dano.size():
		dano[i] *= buff
	barra_vida.max_value = vida
	barra_vida.value = vida

func soltar_corazon():
	if escena_corazon == null:
		return
	if randf() > probabilidad_soltar_corazon:
		return
	var corazon = escena_corazon.instantiate()
	corazon.global_position = global_position + Vector2(0, 40)
	get_parent().add_child(corazon)
	corazon.inicializar(barra_vida.max_value)
