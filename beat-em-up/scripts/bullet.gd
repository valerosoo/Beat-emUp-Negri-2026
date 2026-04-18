extends Area2D

var velocidad = 400
var dano = 10
var impactando = false
var direccion_vector = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("fly")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if impactando:
		return
	position += direccion_vector * velocidad * delta

func impactar():
	if impactando:
		return
	impactando = true
	velocidad = Vector2.ZERO
	$AnimatedSprite2D.play("impact")

func _on_area_entered(area: Area2D) -> void:
	if impactando:
		return
	if area.is_in_group("HurtBox"):
		var jugador = area.get_parent().get_parent()
		if jugador.is_in_group("jugador"):
			jugador.restar_vida(dano, self) #pinguino o enemigo_3
	impactar()
	

func _on_body_entered(body: Node2D) -> void:
	if impactando:
		return
	impactar()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "impact":
		$AnimatedSprite2D.play("caida_short")
	elif $AnimatedSprite2D.animation == "caida_short":
		queue_free()

func actualizar_rotacion():
	rotation = direccion_vector.angle()
