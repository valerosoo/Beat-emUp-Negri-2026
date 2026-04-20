extends Enemigo
class_name Pinguino_AK

@onready var spawn_bala = $SpawnBala
@onready var radar = $Radar
@onready var attack_area_propio = $AttackArea

@export var escena_bala : PackedScene
@export var cadencia: float = 0.5

var puede_disparar = true
var jugador_en_radar = false
var jugador_en_attack = false

func _ready():
	super._ready()
	frames_bloqueo = range(0, 40)
	frames_de_ataque = []
	dano = [10]
	sprite.animation_finished.disconnect(_on_animated_sprite_2d_animation_finished)
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	sprite.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	await get_tree().process_frame
	radar.body_entered.connect(_on_radar_entered)
	radar.body_exited.connect(_on_radar_exited)
	attack_area_propio.body_entered.connect(_on_attack_entered)
	attack_area_propio.body_exited.connect(_on_attack_exited)
	
func _on_radar_entered(body):
	if body.is_in_group("jugador"):
		jugador_en_radar = true
		if !jugador_en_attack:
			estado = Estado.CHASE
	
func _on_radar_exited(body):
	if body.is_in_group("jugador"):
		jugador_en_radar = false
		estado = Estado.IDLE
		atacando = false
		puede_disparar = true
	
func _on_attack_entered(body):
	if body.is_in_group("jugador"):
		jugador_en_attack = true
		estado = Estado.ATTACK
	
func _on_attack_exited(body):
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
	sprite.play(animaciones["quieto"])
	
func perseguir(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	sprite.play(animaciones["correr"])
	
func atacar():
	if player.muerto:
		return
	velocity = Vector2.ZERO
	if !atacando and puede_disparar:
		atacando = true
		sprite.play(animaciones["atacar"])
	
func _on_animated_sprite_2d_frame_changed():
	if sprite.animation == animaciones["atacar"] and sprite.frame == 3:
		if puede_disparar:
			disparar()
	
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == animaciones["atacar"]:
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
	
	var direccion = (player.global_position - spawn_bala.global_position).normalized()
	bala.direccion_vector = direccion
	bala.actualizar_rotacion()
	
func girar_sprite():
	var dir = player.global_position.x - global_position.x
	if dir > 0:
		sprite.flip_h = false
	elif dir < 0:
		sprite.flip_h = true
