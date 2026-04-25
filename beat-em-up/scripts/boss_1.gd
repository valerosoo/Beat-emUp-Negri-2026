extends CharacterBody2D
class_name  Boss1

enum Estado {IDLE, STUN, ATTACK}

@onready var sprite = $Pivote/AnimatedSprite2D
@onready var spawn1 = $"../Spawn1"
@onready var spawn2 = $"../Spawn2"
@onready var barra_vida
@onready var destino_empuje = $"../DestinoEmpuje"
@onready var barrera = get_parent().get_node("StaticBody2D2").get_node("Barrera")
@onready var barrera_sprite = get_parent().get_node("StaticBody2D2").get_node("Sprite2D")

@export var escena_enemigo : PackedScene
@export var vida_maxima : int = 700
@export var duracion_stun : float = 15.0
@export var golpes_para_stun : int = 6
@export var anim_empuje : String

var vida = vida_maxima
var estado = Estado.IDLE
var enemigos_vivos = 0
var stuneado = false
var golpes_recibidos = 0
var player
var stun_id := 0
var pivote_offset = Vector2.ZERO
var primer_spawn = true
var desactivado = false
var muerto = false


func _ready():
	barrera.set_deferred("disabled", false)
	barrera_sprite.visible = true
	barra_vida = get_tree().get_first_node_in_group("Barra_boss")
	player = get_tree().get_first_node_in_group("jugador")
	sprite.play("bat_idle")
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida
	
func _physics_process(delta):
	if !get_parent().animacion_inicio_terminada:
		return
	if primer_spawn:
		primer_spawn = false
		spawnear_enemigos.call_deferred()
	girar_sprite()
	match estado:
		Estado.IDLE:
			sprite.play("bat_idle")
		Estado.STUN:
			sprite.play("bat_hurt")
			pivote_offset = Vector2(-60, 0)
		Estado.ATTACK:
			pass
	
func spawnear_enemigos():
	var e1 = escena_enemigo.instantiate()
	var e2 = escena_enemigo.instantiate()
	e1.global_position = spawn1.global_position
	e2.global_position = spawn2.global_position
	get_parent().call_deferred("add_child", e1)
	get_parent().call_deferred("add_child", e2)
	enemigos_vivos = 2
	await get_tree().process_frame
	await get_tree().process_frame
	e1.tree_exited.connect(enemigo_muerto)
	e2.tree_exited.connect(enemigo_muerto)
	
func enemigo_muerto():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		call_deferred("iniciar_stun")
	
func iniciar_stun():
	if stuneado:
		return
	barrera.set_deferred("disabled", true)
	barrera_sprite.visible = false
	stuneado = true
	golpes_recibidos = 0
	estado = Estado.STUN
	stun_id += 1
	var mi_id = stun_id
	if !is_inside_tree():
		return
	await get_tree().create_timer(duracion_stun).timeout
	if !is_inside_tree():
		return
	if stuneado and stun_id == mi_id:
		terminar_stun()
	
func terminar_stun():
	if !stuneado:
		return
	barrera.set_deferred("disabled", false)
	barrera_sprite.visible = true
	stuneado = false
	golpes_recibidos = 0
	stun_id += 1
	estado = Estado.IDLE
	await empujar_jugador()
	if !is_inside_tree():
		return
	await get_tree().create_timer(1.0).timeout
	if !is_inside_tree():
		return
	if desactivado: 
		return
	call_deferred("spawnear_enemigos")
	
func restar_vida(dano):
	get_parent().restar_vida_boss(dano)
	if stuneado:
		golpes_recibidos += 1
		parpadeo()
		if golpes_recibidos >= golpes_para_stun:
			terminar_stun()
	
func verificar_muerte():
	if vida <= 0:
		muerto = true
		estado = Estado.IDLE
		queue_free()
		
func empujar_jugador():
	estado = Estado.ATTACK
	$AnimationPlayer.play("empujar_jugador")

func anim_empujar():
	pivote_offset = Vector2(95, -73)
	sprite.play(anim_empuje)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "empujar_jugador":
		player.set_physics_process(false)
		var tween = create_tween()
		tween.tween_property(player, "global_position", destino_empuje.global_position, 0.4)
		await tween.finished
		player.set_physics_process(true)
		pivote_offset = Vector2.ZERO
		estado = Estado.IDLE 

func girar_sprite():
	if player == null:
		return
	var dir = player.global_position.x - global_position.x
	if dir > 0:
		sprite.flip_h = false
		$Pivote.position = pivote_offset
	elif dir < 0:
		sprite.flip_h = true
		$Pivote.position = Vector2(-pivote_offset.x, pivote_offset.y)
	
func desactivar():
	muerto = true
	desactivado = true
	estado = Estado.IDLE
	get_tree().call_group("enemigos_boss", "queue_free")
	enemigos_vivos = 0
	
func parpadeo():
	sprite.modulate = Color(0.851, 0.0, 0.0, 1)
	if !is_inside_tree():
		return
	await get_tree().create_timer(0.15).timeout
	if !is_inside_tree():
		return
	sprite.modulate = Color (1,1,1,1)
