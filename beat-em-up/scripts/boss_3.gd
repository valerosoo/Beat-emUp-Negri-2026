extends Boss2
class_name Boss3

@export var escena_enemigo_3 : PackedScene
@export var spawn_izquierda : Node2D
@export var spawn_derecha : Node2D
@export var probabilidad_lluvia_horizontal : float = 0.5
@export var cantidad_oleadas : int = 3
@export var balas_por_oleada : int = 6
@export var tiempo_entre_balas : float = 0.3
@export var tiempo_entre_oleadas : float = 2.0
@export var doradas_por_oleada : int = 1

var atacando_3 = false

func _ready():
	super._ready()
	sprite.play("idle")
	
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
	if atacando_3:
		return
	iniciar_ataque.call_deferred()
	
func iniciar_ataque():
	if atacando_3:
		return
	atacando_3 = true
	estado = Estado.ATTACK
	sprite.play("shoot_up_3")
	await sprite.animation_finished
	sprite.play("idle")
	spawnear_enemigos_costado()
	
	for oleada in cantidad_oleadas:
		await lanzar_oleada()
		await get_tree().create_timer(tiempo_entre_oleadas).timeout
	
	atacando_3 = false
	estado = Estado.IDLE
	await get_tree().create_timer(2.0).timeout
	elegir_ataque()
	
func lanzar_oleada():
	var es_horizontal = randf() < probabilidad_lluvia_horizontal
	var ancho = get_viewport().get_visible_rect().size.x
	var alto = get_viewport().get_visible_rect().size.y
	var x_min = player.global_position.x - ancho / 2 + 50
	var x_max = player.global_position.x + ancho / 2 - 50
	var y_min = player.global_position.y - alto / 2 + 100
	var y_max = player.global_position.y + alto / 2 - 100
	
	var todos = range(balas_por_oleada)
	todos.shuffle()
	var indices_dorados = todos.slice(0, doradas_por_oleada)
	
	for i in balas_por_oleada:
		var escena = escena_bala_verde if i in indices_dorados else escena_bala
		var bala = escena.instantiate()
		get_parent().add_child(bala)
		bala.duenio = self
		if es_horizontal:
			var va_izquierda = randf() < 0.5
			bala.global_position = Vector2(x_min if va_izquierda else x_max, randf_range(y_min, y_max))
			bala.direccion_vector = Vector2(1 if va_izquierda else -1, 0)
		else:
			bala.global_position = Vector2(randf_range(x_min, x_max), player.global_position.y - 600)
			bala.direccion_vector = Vector2.DOWN
		bala.actualizar_rotacion()
		await get_tree().create_timer(tiempo_entre_balas).timeout
	
func spawnear_enemigos_costado():
	var e = escena_enemigo_3.instantiate()
	var spawn
	if randf() < 0.5:
		spawn = spawn_derecha
	else:
		spawn = spawn_izquierda
	e.global_position = spawn.global_position
	get_parent().add_child(e)
	
func restar_vida(dano):
	get_parent().restar_vida_boss(dano) 
	
