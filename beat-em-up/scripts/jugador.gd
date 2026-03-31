extends CharacterBody2D
class_name Jugador

@onready var attack_offset = $AttackArea.position.x

@export var walk_speed = 200
@export var run_speed = 300
var attacking = false

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("D") - Input.get_action_strength("A")
	direction.y = Input.get_action_strength("S") - Input.get_action_strength("W")
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = attack_offset
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = -attack_offset
	
	var current_speed = walk_speed
	
	if !attacking:
		
		if direction.length() > 0 and Input.is_action_pressed("Shift"):
			correr()
			current_speed = run_speed
		elif direction.length() > 0:
			caminar()
			current_speed = walk_speed
		else:
			$AnimatedSprite2D.play("idle")
			
	velocity = direction.normalized() * current_speed
	move_and_slide()
	
	if Input.is_action_just_pressed("Click_izq") and !attacking:
		attack()

	if Input.is_action_just_released("Click_izq") and attacking:
		cancel_attacking()
	
	if attacking:
		if $AnimatedSprite2D.frame==0 || $AnimatedSprite2D.frame==5 || $AnimatedSprite2D.frame==15:
			activar_hitbox_golpeo()
		else:
			desactivar_hitbox_golpeo()
	
func attack():
	attacking = true
	$AnimatedSprite2D.play("combo")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "combo":
		attacking = false
		$AttackArea.monitoring = false
		
		if Input.is_action_pressed("Click_izq"):
			attack()

func _on_attack_area_body_entered(body: Node2D):
	if body.is_in_group("enemigo"):
		print("golpeaste enemigo")

func cancel_attacking():
	attacking = false
	$AnimatedSprite2D.play("idle")
	
func correr():
	$AnimatedSprite2D.play("run")
	
func caminar():
	$AnimatedSprite2D.play("walk")
	
func activar_hitbox_golpeo():
	$AttackArea.monitoring = true
	
func desactivar_hitbox_golpeo():
	$AttackArea.monitoring = false
