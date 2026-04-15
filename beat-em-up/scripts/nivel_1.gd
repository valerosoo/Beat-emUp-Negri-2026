extends Node2D

@onready var camara = $Camera2D
@onready var jugador = $Jugador
@onready var game_over = $CanvasLayer/GameOver

@export var oleada_1 : Array[ResourceOleadas] = []
@export var oleada_2 : Array[ResourceOleadas] = []
@export var oleada_3 : Array[ResourceOleadas] = []

var esperando_animacion = false
var oleadas

var jugador_nivel_escenas_1 = [1920,2880,4800]
var enemigos_nivel_escenas_1 = [["enemigo_1","enemigo_1"], ["enemigo_1","enemigo_1","enemigo_2"], ["enemigo_1","enemigo_1","enemigo_2","enemigo_2"]]
var oleada = 0
var oleada_iniciada = false
var camara_bloqueada = false
var enemigos_vivos = 0

func _ready() -> void:
	game_over.visible = false
	oleadas = [oleada_1, oleada_2, oleada_3]
	jugador.entrar.connect(jugador_termino_animacion)
	if !GameManager.puede_ir_gulag:
		oleada = GameManager.oleada_actual
		jugador.global_position = GameManager.posicion_muerte
		configurar_oleada()
		get_tree().paused = true
		esperando_animacion = true
	
func _physics_process(delta: float) -> void:
	if esperando_animacion:
		return
	
	if !camara_bloqueada:
		camara.global_position = jugador.global_position
	
	if jugador.global_position.x >= jugador_nivel_escenas_1[oleada] and !oleada_iniciada:
		configurar_oleada()
		spawnear_oleada()

func spawnear_oleada():
	GameManager.oleada_actual = oleada
	for datos in oleadas[oleada]:
		spawnear_enemigo(datos["enemigo"], datos["spawn"])

func spawnear_enemigo(enemigo_packedScene, spawn_nodePath):
	var enemigo = enemigo_packedScene.instantiate()
	add_child(enemigo)
	var spawn = get_node(spawn_nodePath)
	enemigo.global_position = spawn.global_position
	
	enemigos_vivos += 1
	
	enemigo.tree_exited.connect(eliminar_enemigo)
	
	if enemigo.is_in_group("enemigo_2"):
		print("Frames: " + str(enemigo.frames_de_ataque))
		enemigo.anim_caida()
	
func eliminar_enemigo():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		camara_bloqueada = false
		oleada_iniciada = false
		oleada += 1
	
func mostrar_death_screen():
	game_over.visible = true

func configurar_oleada():
	oleada_iniciada = true
	camara_bloqueada = true
	camara.limit_left = jugador_nivel_escenas_1[oleada] - (get_viewport().get_visible_rect().size.x)/2
	camara.limit_right = jugador_nivel_escenas_1[oleada] + (get_viewport().get_visible_rect().size.x)
	
func jugador_termino_animacion():
	if esperando_animacion:
		esperando_animacion = false
		spawnear_oleada()
