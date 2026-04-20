extends Enemigo

var pivot_offset = Vector2.ZERO

func _ready():
	super._ready()
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func idle(delta):
	velocity = Vector2.ZERO
	if animation_player.current_animation != animaciones["quieto"]:
		animation_player.play(animaciones["quieto"])

func perseguir(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	if animation_player.current_animation != animaciones["correr"]:
		animation_player.play(animaciones["correr"])
	if distancia < distancia_para_atacar:
		estado = Estado.ATTACK

func atacar():
	if player.muerto == true:
		return
	velocity = Vector2.ZERO
	if distancia > distancia_para_atacar:
		atacando = false
		estado = Estado.CHASE
		return
	if !atacando:
		atacando = true
		sprite.frame = 0
		animation_player.play(animaciones["atacar"])
		
func verificar_muerte():
	if vida <= 0:
		estado = Estado.DEATH
		$CollisionShape2D.visible = false
		set_collision_layer(0)
		set_collision_mask(0)
		soltar_corazon()
		velocity = Vector2.ZERO
		animation_player.play(animaciones["morir"])

var pivot_offset_base = Vector2.ZERO

func girar_sprite():
	if attack_offset == null:
		attack_offset = attack_area.position.x
	if player == null:
		return
	var dir = player.global_position.x - global_position.x
	if dir > 0:
		sprite.flip_h = false
		$AttackArea.position.x = attack_offset
		$Pivote.position = pivot_offset
	elif dir < 0:
		sprite.flip_h = true
		$AttackArea.position.x = -attack_offset
		$Pivote.position = Vector2(-pivot_offset.x, pivot_offset.y)

func anim_idle():
	sprite.play("bat_idle")
	pivot_offset = Vector2(0, 0)
	
func anim_atacar():
	sprite.play("bat_attack")
	pivot_offset = Vector2(30, -20)

func anim_run():
	sprite.play("bat_run")
	pivot_offset = Vector2(0, 0)

func anim_morir():
	sprite.play("bat_death")
	pivot_offset = Vector2(-57, 14)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == animaciones["morir"]:
		queue_free()
	elif anim_name == "Caer":
		cayendo = false
