extends Node2D

@onready var camara = $Camera2D
@onready var jugador = $Jugador

var jugador_nivel_escenas_1 = [1920,2880,4800]
var enemigos_nivel_escenas_1 = [["enemigo_1","enemigo_1"], ["enemigo_1","enemigo_1","enemigo_2"], ["enemigo_1","enemigo_1","enemigo_2","enemigo_2"]]
var oleadas = [
	[{"enemigo" : "res://scenes/enemigo_1.tscn", "spawn": "Spawnpoints/Oleada1/enemigo_1_izq"},
	{"enemigo" : "res://scenes/enemigo_1.tscn", "spawn": "Spawnpoints/Oleada1/enemigo_1_der"}],
	[{"enemigo" : "res://scenes/enemigo_1.tscn", "spawn": "Spawnpoints/Oleada2/enemigo_1_izq"},
	{"enemigo" : "res://scenes/enemigo_1.tscn", "spawn": "Spawnpoints/Oleada2/enemigo_1_der"},
	{"enemigo" : "res://scenes/enemigo_2.tscn", "spawn" : "Spawnpoints/Oleada2/enemigo_2_arr"}]
]
var oleada = 0
var oleada_iniciada = false
var camara_bloqueada = false
var enemigos_vivos = 0

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if !camara_bloqueada:
		camara.global_position = jugador.global_position
	
	
	if jugador.global_position.x >= jugador_nivel_escenas_1[oleada] and !oleada_iniciada:
		oleada_iniciada = true
		camara_bloqueada = true
		camara.limit_left = jugador_nivel_escenas_1[oleada] - (get_viewport().get_visible_rect().size.x)/2
		camara.limit_right = jugador_nivel_escenas_1[oleada] + (get_viewport().get_visible_rect().size.x)
		spawnear_oleada()

func spawnear_oleada():
	for datos in oleadas[oleada]:
		spawnear_enemigo(datos["enemigo"], datos["spawn"])

func spawnear_enemigo(enemigo_ruta, spawn_ruta):
	var enemigo = load(enemigo_ruta).instantiate()
	add_child(enemigo)
	var pos_final = get_node(spawn_ruta).global_position
	
	var spawn = get_node(spawn_ruta)
	print("Spawn encontrado:", spawn)
	print("Pos spawn:", spawn.global_position)
	
	enemigos_vivos += 1
	enemigo.global_position = pos_final
	enemigo.tree_exited.connect(eliminar_enemigo)
	
func eliminar_enemigo():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		camara_bloqueada = false
		oleada_iniciada = false
		oleada += 1
	
