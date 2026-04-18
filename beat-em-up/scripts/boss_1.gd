extends CharacterBody2D

enum Estado {IDLE, STUN}

@onready var sprite = $AnimatedSprite2D
@onready var spawn1 = $"../Spawn1"
@onready var spawn2 = $"../Spawn2"
@onready var barra_vida

@export var escena_enemigo : PackedScene
@export var vida_maxima = 200
@export var duracion_stun = 15.0
@export var golpes_para_stun = 6

var vida = 200
var estado = Estado.IDLE
var enemigos_vivos = 0
var stuneado = false
var golpes_recibidos = 0
var player

func _ready():
	barra_vida = get_tree().get_first_node_in_group("Barra_boss")
	player = get_tree().get_first_node_in_group("jugador")
	sprite.play("bat_idle")
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida
	spawnear_enemigos.call_deferred()
	
func _physics_process(delta):
	
	match estado:
		Estado.IDLE:
			sprite.play("bat_idle")
		Estado.STUN:
			sprite.play("bat_hurt")
	
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
	stuneado = true
	golpes_recibidos = 0
	estado = Estado.STUN
	await get_tree().create_timer(duracion_stun).timeout
	terminar_stun()
	
func terminar_stun():
	if !stuneado:
		return
	stuneado = false
	estado = Estado.IDLE
	spawnear_enemigos()
	
func restar_vida(dano):
	if !stuneado:
		return
	vida -= dano
	golpes_recibidos += 1
	barra_vida.value = vida
	if golpes_recibidos >= golpes_para_stun:
		terminar_stun()
	verificar_muerte()
	
func verificar_muerte():
	if vida <= 0:
		estado = Estado.IDLE
		queue_free()
		
		
		
		
