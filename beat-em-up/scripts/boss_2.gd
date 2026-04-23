extends Boss1
class_name Boss2

@export var escena_bala : PackedScene
@export var escena_bala_verde : PackedScene
@export var cantidad_balas : int = 30
@export var cantidad_balas_doradas : int = 6

var ataque_actual = 0
var atacando = false
var danio_bala

func _ready():
	super._ready()
	danio_bala =  BalaVerde.danio
	sprite.play("idle")
	await ciclo_ataques()
	
func ciclo_ataques():
	while true:
		await elegir_ataque()
		await get_tree().create_timer(1.0).timeout
	
func _physics_process(delta):
	if !get_parent().animacion_inicio_terminada:
		return
	girar_sprite()
	match estado:
		Estado.IDLE:
			sprite.play("idle")
		Estado.STUN:
			sprite.play("hit")
	
func elegir_ataque():
	if atacando:
		return
	atacando = true
	ataque_actual = (ataque_actual + 1) % 2
	if ataque_actual == 0:
		await spawnear_pinguinos()
	else:
		await iniciar_lluvia_balas()
	atacando = false
	
func spawnear_pinguinos():
	spawnear_enemigos()
	while enemigos_vivos > 0:
		await get_tree().process_frame
	while stuneado:
		await get_tree().process_frame
	
func enemigo_muerto():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		iniciar_stun()
	
func iniciar_lluvia_balas():
	estado = Estado.ATTACK
	await empujar_jugador()
	sprite.play("shoot_up_3")
	await sprite.animation_finished
	await hacer_caer_balas()
	
func hacer_caer_balas():
	var todos = range(cantidad_balas)
	todos.shuffle()
	var indices_dorados = todos.slice(0, cantidad_balas_doradas)
	
	var rect = get_viewport().get_visible_rect()

	var x_min = rect.position.x + 50
	var x_max = rect.position.x + rect.size.x - 50

	for i in cantidad_balas:
		if muerto:
			return
		var escena = escena_bala_verde if i in indices_dorados else escena_bala
		var bala = escena.instantiate()
		get_parent().add_child(bala)
		bala.set_collision_mask_value(6, false)
		bala.duenio = self
		bala.global_position = Vector2(randf_range(x_min, x_max), - 700)
		bala.direccion_vector = Vector2.DOWN
		bala.actualizar_rotacion()
		await get_tree().create_timer(0.25).timeout
	if muerto:
		return
	estado = Estado.IDLE
	await get_tree().create_timer(2.0).timeout
	
func terminar_stun():
	if !stuneado:
		return
	stuneado = false
	empujar_jugador()
	golpes_recibidos = 0
	stun_id += 1
	estado = Estado.IDLE
	
func empujar_jugador():
	estado = Estado.ATTACK
	$AnimationPlayer.play("empujar_jugador")
	await $AnimationPlayer.animation_finished

func anim_empujar():
	pivote_offset = Vector2(122, -77)
	sprite.play(anim_empuje)
	
func _on_animation_player_animation_finished(anim_name : StringName):
	if anim_name == "empujar_jugador":
		player.set_physics_process(false)
		var tween = create_tween()
		tween.tween_property(player, "global_position", destino_empuje.global_position, 0.4)
		await tween.finished
		player.set_physics_process(true)
		pivote_offset = Vector2.ZERO

func iniciar_stun():
	if stuneado:
		return
	stuneado = true
	golpes_recibidos = 0
	estado = Estado.STUN
	stun_id += 1
	var mi_id = stun_id
	await get_tree().create_timer(duracion_stun).timeout
	if stuneado and stun_id == mi_id:
		terminar_stun()
		
