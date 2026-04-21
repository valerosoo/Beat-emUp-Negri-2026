extends CharacterBody2D

var velocidad = 400
var dano = 10
var impactando = false
var direccion_vector = Vector2.RIGHT
var duenio : Node = null

func _ready() -> void:
	$AnimatedSprite2D.play("fly")
	
func _physics_process(delta: float) -> void:
	if impactando:
		return
	velocity = direccion_vector * velocidad
	var colision = move_and_collide(velocity * delta)
	if colision:
		impactar()
		
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("HurtBox"):
			var jugador = area.get_parent().get_parent()
			if jugador.is_in_group("jugador"):
				jugador.restar_vida(dano, duenio)
			impactar()
			return
	
func impactar():
	if impactando:
		return
	impactando = true
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("impact")
	
func _on_area_entered(area: Area2D) -> void:
	if impactando:
		return
	if area.is_in_group("HurtBox"):
		var jugador = area.get_parent().get_parent()
		if jugador.is_in_group("jugador"):
			jugador.restar_vida(dano, self)
	impactar()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "impact":
		$AnimatedSprite2D.play("caida_short")
	elif $AnimatedSprite2D.animation == "caida_short":
		queue_free()
	
func actualizar_rotacion():
	rotation = direccion_vector.angle()
	
	
