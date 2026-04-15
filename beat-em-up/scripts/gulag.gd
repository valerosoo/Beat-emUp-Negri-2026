extends Node2D

@onready var fondo = $Fondo
@onready var spawn_enemigo = $SpawnEnemigo
@onready var spawn_jugador = $SpawnJugador
@onready var jugador = $Jugador
@onready var gameover = $GameOver

var enemigo
var cinematica_iniciada = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameover.visible = false
	jugador.global_position = spawn_jugador.global_position
	GameManager.puede_ir_gulag = false
	jugador.entrar.connect(volver_al_nivel)
	
	if GameManager.gulag.fondo != null:
		fondo.texture = load(GameManager.gulag.fondo)
		
	var enemigo_scene = load(GameManager.gulag.enemigo)
	enemigo = enemigo_scene.instantiate()
	add_child(enemigo)
	
	enemigo.global_position = spawn_enemigo.global_position
	
	enemigo.vida *= GameManager.gulag.buff
	enemigo.speed *= GameManager.gulag.buff
	for i in enemigo.dano.size():
		enemigo.dano[i] *= GameManager.gulag.buff
	
	enemigo.tree_exited.connect(iniciar_cinematica)
	print("señal conectada")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
		
func mostrar_death_screen():
	gameover.visible = true

func volver_al_nivel():
	get_tree().paused = false
	GameManager.volver_al_nivel()

func iniciar_cinematica():
	print("iniciar_cinematica llamada")
	if !cinematica_iniciada:
		cinematica_iniciada = true
		if get_tree() != null:
			get_tree().paused = true
		jugador.set_physics_process(false)
		$Jugador/Pivote/AnimationPlayer.play("entrar")
