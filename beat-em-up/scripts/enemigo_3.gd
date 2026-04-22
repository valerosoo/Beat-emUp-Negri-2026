extends Enemigo
class_name Pinguino_AK

@onready var spawn_bala = $SpawnBala
@onready var radar = $Radar
@onready var attack_area_propio = $AttackArea

@export var escena_bala : PackedScene
@export var cadencia: float = 0.0

var puede_disparar = true
var jugador_en_radar = false
var jugador_en_attack = false
var pivot_offset = Vector2.ZERO
var spawn_bala_offset

func _ready():
	super._ready()
	spawn_bala_offset = spawn_bala.position.x
	frames_bloqueo = range(0, 40)
	frames_de_ataque = []
	dano = [10]
	animation_player.animation_finished.connect(_on_animation_player_finished)
	await get_tree().process_frame
	
func _on_radar_entered(body):
	print("Radar detectó: ", body.name, " grupos: ", body.get_groups())
	if body.is_in_group("jugador"):
		jugador_en_radar = true
		if !jugador_en_attack:
			estado = Estado.CHASE
	
func _on_radar_exited(body):
	if estado == Estado.DEATH:
		return
	if body.is_in_group("jugador"):
		jugador_en_radar = false
		estado = Estado.IDLE
		atacando = false
		puede_disparar = true
	
func _on_attack_entered(body):
	print("AttackArea detectó: ", body.name)
	if body.is_in_group("jugador"):
		jugador_en_attack = true
		estado = Estado.ATTACK
	
func _on_attack_exited(body):
	if estado == Estado.DEATH:
		return
	if body.is_in_group("jugador"):
		jugador_en_attack = false
		atacando = false
		puede_disparar = true
		if jugador_en_radar:
			estado = Estado.CHASE
		else:
			estado = Estado.IDLE
	
func _physics_process(delta):
	if !ia_activa:
		return
	if estado == Estado.DEATH:
		return
	if player.muerto:
		return
		
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
	animation_player.play(animaciones["quieto"])
	
func perseguir(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	animation_player.play(animaciones["correr"])
	
func atacar():
	if player.muerto:
		return
	velocity = Vector2.ZERO
	if !atacando and puede_disparar:
		atacando = true
		animation_player.play(animaciones["atacar"])
	
func _on_animation_player_finished(anim_name: StringName):
	print("AnimationPlayer terminó: ", anim_name)
	if anim_name == animaciones["atacar"]:
		atacando = false
		puede_disparar = false
		await get_tree().create_timer(cadencia).timeout
		puede_disparar = true
		
func disparar():
	if estado == Estado.DEATH:
		return
	
	var bala = escena_bala.instantiate()
	get_parent().add_child(bala)
	
	bala.global_position = spawn_bala.global_position
	bala.dano = dano[0]
	bala.duenio = self
	
	var direccion = (player.global_position - spawn_bala.global_position).normalized()
	bala.direccion_vector = direccion
	bala.actualizar_rotacion()
	
func girar_sprite():
	if attack_offset == null:
		attack_offset = attack_area.position.x
	if player == null:
		return
	var dir = player.global_position.x - global_position.x
	if dir > 0:
		sprite.flip_h = false
		$AttackArea.position.x = attack_offset
		$Pivote.position = pivot_offset
		spawn_bala.position.x = abs(spawn_bala_offset)
	elif dir < 0:
		sprite.flip_h = true
		$AttackArea.position.x = -attack_offset
		$Pivote.position = Vector2(-pivot_offset.x, pivot_offset.y)
		spawn_bala.position.x = -abs(spawn_bala_offset)
		
	match sprite.animation:
		"shoot":
			if sprite.flip_h:
				pivot_offset = Vector2(92, 0)
			else:
				pivot_offset = Vector2(43, 0)
		"idle":
			if sprite.flip_h:
				pivot_offset = Vector2(53, 0)
			else:
				pivot_offset = Vector2(0, 0)
		"run":
			if sprite.flip_h:
				pivot_offset = Vector2(55, 0)
			else:
				pivot_offset = Vector2(0, 0)
		"death":
			if sprite.flip_h:
				pivot_offset = Vector2(58, 11)
			else:
				pivot_offset = Vector2(0, 0)
			
func anim_idle():
	sprite.play("idle")
	if sprite.flip_h:
		pivot_offset = Vector2(53, 0)
	else:
		pivot_offset = Vector2(0, 0)
	
func anim_atacar():
	sprite.play("shoot")
	if sprite.flip_h:
		pivot_offset = Vector2(92, 0)
	else:
		pivot_offset = Vector2(43, 0)

func anim_run():
	sprite.play("run")
	if sprite.flip_h:
		pivot_offset = Vector2(55, 0)
	else:
		pivot_offset = Vector2(0, 0)

func anim_morir():
	sprite.play("death")
	if sprite.flip_h:
		pivot_offset = Vector2(58, 11)
	else:
		pivot_offset = Vector2(0, 0)

func verificar_muerte():
	if vida <= 0:
		estado = Estado.DEATH
		velocity = Vector2.ZERO
		atacando = false
		$CollisionShape2D.disabled = true
		set_collision_layer(0)
		set_collision_mask(0)
		soltar_corazon()
		animation_player.play(animaciones["morir"])
		await animation_player.animation_finished
		queue_free()
