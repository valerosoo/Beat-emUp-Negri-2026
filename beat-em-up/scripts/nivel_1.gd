extends Node2D
class_name Nivel1

@onready var camara = $Camera2D
@onready var jugador = $Jugador
@onready var game_over = $CanvasLayer/GameOver
@onready var pared_izq = $Colisiones/Pared_izq
@onready var pared_der = $Colisiones/Pared_der

@export var num_nivel: int = 1
@export var oleada_1 : Array[ResourceOleadas] = []
@export var oleada_2 : Array[ResourceOleadas] = []
@export var oleada_3 : Array[ResourceOleadas] = []

var esperando_animacion = false
var oleadas

var jugador_oleadas_activacion = [1920,2880,3840]
var oleada = 0
var oleada_iniciada = false
var camara_bloqueada = false
var enemigos_vivos = 0
var regresando_del_gulag = false
var animacion_final_frame = 5300
var animacion_final_iniciada = false

func _ready() -> void:
	if GameManager.viene_del_gulag or not GameManager.puede_ir_gulag:
		GameManager.continuar_siguiente_nivel()
	else:
		GameManager.iniciar_partida()
	game_over.visible = false
	oleadas = [oleada_1, oleada_2, oleada_3]
	jugador.entrar.connect(jugador_termino_animacion)
	
	if GameManager.viene_del_gulag:
		regresando_del_gulag = true
		oleada = GameManager.oleada_actual
		jugador.global_position = GameManager.posicion_muerte
		configurar_oleada()
		GameManager.viene_del_gulag = false  
	elif !GameManager.puede_ir_gulag:
		oleada = GameManager.oleada_actual
		jugador.global_position = GameManager.posicion_muerte
		configurar_oleada()
		get_tree().paused = true
		esperando_animacion = true
	
func _physics_process(delta: float) -> void:
	if esperando_animacion:
		return
	
	if jugador.global_position.x >= animacion_final_frame and !animacion_final_iniciada:
		activar_animacion_final()
	
	if !camara_bloqueada:
		camara.global_position = jugador.global_position
	
	if oleada >= oleadas.size():
		return
	
	if jugador.global_position.x >= jugador_oleadas_activacion[oleada] and !oleada_iniciada:
		mover_paredes()
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
		liberar_camara()
		desactivar_pared_der()
	
func mostrar_death_screen():
	game_over.mostrar_stats()
	game_over.visible = true

func configurar_oleada():
	oleada_iniciada = true
	camara_bloqueada = true
	camara.limit_left = jugador_oleadas_activacion[oleada] - (get_viewport().get_visible_rect().size.x)/2   
	camara.limit_right = jugador_oleadas_activacion[oleada] + (get_viewport().get_visible_rect().size.x)
	
func jugador_termino_animacion():
	if regresando_del_gulag:
		regresando_del_gulag = false
		spawnear_oleada()
		return
	if esperando_animacion:
		esperando_animacion = false
		spawnear_oleada()
	
func liberar_camara():
	camara.limit_left = -10000000
	camara.limit_right = 10000000
	
func activar_animacion_final():
	GameManager.viene_del_nivel_anterior = true
	animacion_final_iniciada = true
	jugador.set_physics_process(false)
	
	jugador.caminar()
	
	$CanvasLayer/Barra_vida.visible = false
	var tween = create_tween()
	tween.tween_property(jugador, "global_position", Vector2(5559, 855), 1.5)
	await tween.finished
	
	$AnimationPlayer.play("Abrir_entrar")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Abrir_entrar":
		get_tree().change_scene_to_file("res://scenes/nivel_2.tscn")

func mover_paredes():
	pared_izq.global_position.x = jugador_oleadas_activacion[oleada] - (get_viewport().get_visible_rect().size.x)/2  
	pared_der.global_position.x = jugador_oleadas_activacion[oleada] + (get_viewport().get_visible_rect().size.x)/2 
	
func desactivar_pared_der():
	pared_der.global_position.x = pared_izq.global_position.x

func termino_nivel():
	ManejadorGuardado.niveles.niveles_desbloqueados += 1
