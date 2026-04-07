extends Node2D

@onready var fondo = $Fondo
@onready var spawn_enemigo = $SpawnEnemigo
@onready var spawn_jugador = $SpawnJugador
@onready var jugador = $Jugador

var enemigo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jugador.global_position = spawn_jugador.global_position
	GameManager.puede_ir_gulag = false
	
	if GameManager.gulag.fondo != null:
		fondo.texture = load(GameManager.gulag.fondo)
		print("Fondo: " + GameManager.gulag.fondo)
		
	var enemigo_scene = load(GameManager.gulag.enemigo)
	print("Enemigo:", GameManager.gulag.enemigo)
	enemigo = enemigo_scene.instantiate()
	add_child(enemigo)
	
	enemigo.global_position = spawn_enemigo.global_position
	
	enemigo.vida *= GameManager.gulag.buff
	enemigo.speed *= GameManager.gulag.buff
	for i in enemigo.dano.size():
		enemigo.dano[i] *= GameManager.gulag.buff

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemigo.vida <= 0:
		GameManager.retry_level()
