extends CharacterBody2D
class_name Jugador

signal entrar

@onready var attack_offset = $Pivote/AttackArea.position.x
@onready var barra_vida = get_tree().get_first_node_in_group("barra_vida")

@export var walk_speed: int = 200
@export var run_speed: int = 300
@export var dano: Array = [10, 15, 30]
@export var vida_maxima: int = 100
@export var frames_de_ataque: Array = [1,5,15]
@export var tiempo_escudo: float = 0.5
@export var tiempo_para_otro_escudo: int = 2

var attacking = false
var puede_bloquear = true

#Para los saltos
var z = 0
var velocidad_z = 0
var gravedad = 1200
var fuerza_salto = 500
var saltando = false

var muerto = false
var vida

func _ready() -> void:
	$Pivote/Escudo/AnimatedSprite2D.visible = false
	if GameManager.stats_jugador == null:
		GameManager.stats_jugador = exportar_stats()
		vida = vida_maxima
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_maxima
	else:
		aplicar_stats(GameManager.stats_jugador)
	
	vida = vida_maxima
	barra_vida.value = vida_maxima
	
	if GameManager.viene_del_gulag:
		GameManager.viene_del_gulag = false
		iniciar_salida_portal()
	
func _physics_process(delta: float) -> void:
	
	if muerto:
		return
	
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("D") - Input.get_action_strength("A")
	direction.y = Input.get_action_strength("S") - Input.get_action_strength("W")
	
	if direction.x > 0:
		$Pivote/AnimatedSprite2D.flip_h = false
		$Pivote/AttackArea.position.x = attack_offset
	elif direction.x < 0:
		$Pivote/AnimatedSprite2D.flip_h = true
		$Pivote/AttackArea.position.x = -attack_offset
	
	var current_speed = walk_speed
	
	if !attacking:
		
		if direction.length() > 0 and Input.is_action_pressed("Shift"):
			if !saltando:
				correr()
			current_speed = run_speed
		elif direction.length() > 0:
			if !saltando:
				caminar()
			current_speed = walk_speed
		else:
			if !saltando:
				$Pivote/AnimatedSprite2D.play("idle")
			current_speed = walk_speed
		
	velocity = direction.normalized() * current_speed
	move_and_slide()
	
	if Input.is_action_just_pressed("Click_izq") and !attacking:
		attack()
		
	if Input.is_action_just_released("Click_izq") and attacking:
		cancel_attacking()
		
	if Input.is_action_just_pressed("Espacio") and z == 0:
		saltar()
	
	if z > 0 or velocidad_z > 0:
		velocidad_z -= gravedad * delta
		z += velocidad_z * delta
		
		if z <= 0:
			z = 0
			velocidad_z = 0
			saltando = false
			$Pivote/AnimatedSprite2D.play("idle")
		
	$Pivote.position.y = -z
	
	if z <= 0 and saltando:
		$Pivote/AnimatedSprite2D.play("idle")
		
	if Input.is_action_just_pressed("Click_der") and !attacking:
		bloquear()
		
func attack():
	attacking = true
	$Pivote/AnimatedSprite2D.play("combo")

func _on_animated_sprite_2d_animation_finished():
	if $Pivote/AnimatedSprite2D.animation == "combo":
		attacking = false
		$Pivote/AttackArea.monitoring = false
		
		if Input.is_action_pressed("Click_izq"):
			attack()
		
	elif $Pivote/AnimatedSprite2D.animation == "death":
		if GameManager.puede_ir_gulag:
			GameManager.puede_ir_gulag = false
			get_tree().change_scene_to_file("res://scenes/continue.tscn")
		else:
			get_parent().mostrar_death_screen()
			
	if $Pivote/Escudo/AnimatedSprite2D.animation == "destroy":
		$Pivote/Escudo/AnimatedSprite2D.visible = false

func cancel_attacking():
	attacking = false
	desactivar_hitbox_golpeo()
	$Pivote/AnimatedSprite2D.play("idle")
	
func correr():
	$Pivote/AnimatedSprite2D.play("run")
	
func caminar():
	$Pivote/AnimatedSprite2D.play("walk")
	
func activar_hitbox_golpeo():
	$Pivote/AttackArea.monitoring = true
	
func desactivar_hitbox_golpeo():
	$Pivote/AttackArea.monitoring = false

func _on_animated_sprite_2d_frame_changed():
	if !attacking:
		desactivar_hitbox_golpeo()
		return
	
	if muerto:
		return
		
	var frame = $Pivote/AnimatedSprite2D.frame
	
	if frame in frames_de_ataque:
		activar_hitbox_golpeo()
	else:
		desactivar_hitbox_golpeo()

func restar_vida(dano, enemigo):
	if $Pivote/Escudo.monitoring == true:
		return
		
	vida -= dano
	barra_vida.value = vida
	parpadeo()
	verificar_muerte(enemigo)
	
func sumar_vida(suma):
	vida += suma
	
func verificar_muerte(enemigo):
	if muerto:
		return
		
	if vida <= 0:
		muerto = true
		if !GameManager.puede_ir_gulag:
			$Pivote/AnimatedSprite2D.speed_scale = 0.6
		$Pivote/AnimatedSprite2D.play("death")
		if GameManager.puede_ir_gulag:
			GameManager.posicion_muerte = global_position
			GameManager.gulag.enemigo = enemigo.scene_file_path
			GameManager.gulag.fondo = "res://assets/Mapas/" + str(GameManager.nivel_actual) + "/Bright/City" + str(GameManager.nivel_actual) + ".png"
			
func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtBox") and area.get_parent().is_in_group("enemigo"):
		var enemigo = area.get_parent()
		var frame = $Pivote/AnimatedSprite2D.frame
		var index = frames_de_ataque.find(frame)
		var dano_golpe = dano[index]
		enemigo.restar_vida(dano_golpe)

func saltar():
	saltando = true
	velocidad_z = fuerza_salto
	$Pivote/AnimatedSprite2D.play("jump")

func bloquear():
	if !puede_bloquear:
		return
	$Pivote/Escudo/AnimatedSprite2D.visible = true
	puede_bloquear = false
	$Pivote/Escudo.monitoring = true
	
	await get_tree().process_frame
	var areas = $Pivote/Escudo.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("AttackArea") and area.get_parent().is_in_group("enemigo"):
			if area.get_parent().atacando:
				area.get_parent().stun()
			
		
	await get_tree().create_timer(tiempo_escudo).timeout
	$Pivote/Escudo/AnimatedSprite2D.play("destroy")
	$Pivote/Escudo.monitoring = false
	await get_tree().create_timer(tiempo_para_otro_escudo).timeout
	puede_bloquear = true

func _on_escudo_area_entered(area: Area2D) -> void:
	if area.is_in_group("AttackArea") and area.get_parent().is_in_group("enemigo"):
		var enemigo = area.get_parent()
		if enemigo.atacando and enemigo.estado != Enemigo.Estado.DEATH:
			enemigo.stun()
		
func resetear():
	vida = vida_maxima
	muerto = false
	
	barra_vida.value = vida_maxima
	$Pivote/AnimatedSprite2D.play("idle")

func parpadeo():
	$Pivote/AnimatedSprite2D.modulate = Color(0.851, 0.0, 0.0, 1)
	await get_tree().create_timer(0.15).timeout
	$Pivote/AnimatedSprite2D.modulate = Color (1,1,1,1)
	
func exportar_stats():
	return {
		"vida_maxima" : vida_maxima,
		"walk_speed" : walk_speed,
		"run_speed" : run_speed,
		"dano" : dano.duplicate(),
		"tiempo_escudo" : tiempo_escudo,
		"tiempo_para_otro_escudo" : tiempo_para_otro_escudo
	}
	
func aplicar_stats(stats):
	vida_maxima = stats["vida_maxima"]
	walk_speed = stats["walk_speed"]
	run_speed = stats["run_speed"]
	dano = stats["dano"]
	tiempo_escudo = stats["tiempo_escudo"]
	tiempo_para_otro_escudo = stats["tiempo_para_otro_escudo"]
	
	vida = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_maxima


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "entrar":
		entrar.emit()
	elif anim_name == "salir":
		get_tree().paused = false
		set_physics_process(true)
		entrar.emit()

func iniciar_salida_portal():
	set_physics_process(false)
	$Pivote/AnimationPlayer.play("salir")
