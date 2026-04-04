extends CharacterBody2D
class_name Jugador

@onready var attack_offset = $Pivote/AttackArea.position.x
@onready var barra_vida = get_tree().get_first_node_in_group("barra_vida")

@export var walk_speed = 200
@export var run_speed = 300
@export var dano = [10, 15, 30]
@export var vida = 100
@export var frames_de_ataque = [1,5,15]
var attacking = false

#Para los saltos
var z := 0
var velocidad_z := 0
var gravedad := 1200
var fuerza_salto := 500
var saltando := false
var muerto = false

func _ready() -> void:
	pass
	
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
			correr()
			current_speed = run_speed
		elif direction.length() > 0:
			caminar()
			current_speed = walk_speed
		else:
			$Pivote/AnimatedSprite2D.play("idle")
			
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
			get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

func cancel_attacking():
	attacking = false
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
		return
		
	var frame = $Pivote/AnimatedSprite2D.frame
	
	if frame == 0 or frame == 5 or frame == 15:
		activar_hitbox_golpeo()
	else:
		desactivar_hitbox_golpeo()

func restar_vida(dano, enemigo):
	vida -= dano
	barra_vida.value = vida
	verificar_muerte(enemigo)
	
func sumar_vida(suma):
	vida += suma
	
func verificar_muerte(enemigo):
	if muerto:
		return
	if vida <= 0:
		muerto = true
		$Pivote/AnimatedSprite2D.play("death")
		
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
