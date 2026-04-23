extends Bala
class_name BalaVerde

func _ready():
	super._ready()
	
func _physics_process(delta):
	super._physics_process(delta)
	
	if impactando:
		return
		
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("AttackArea"):
			var jugador = area.owner
			
			if jugador and jugador.is_in_group("jugador") and jugador.attacking:
				redirigir_al_boss()
				return

func _on_area_2d_area_entered(area: Area2D) -> void:
	if impactando:
		return
	
	if area.is_in_group("AttackArea"):
		return
	
	if area.is_in_group("HurtBox"):
		var boss_node = area.get_parent()
		
		if boss_node and boss_node.has_method("restar_vida"):
			boss_node.restar_vida(10)
			queue_free()
			return
	
	super._on_area_entered(area)
	
func redirigir_al_boss():
	if duenio == null:
		return
	direccion_vector = (duenio.global_position - global_position).normalized()
	velocidad = 800
	actualizar_rotacion()
	$Area2D.collision_mask = 1 << 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if impactando:
		return
	
	if body.is_in_group("boss_2"):
		body.restar_vida(10)
		queue_free()
