extends Nivel1

func _ready() -> void:
	GameManager.sonido_menu_stop()
	if GameManager.viene_del_nivel_anterior:
		GameManager.continuar_siguiente_nivel()
		GameManager.viene_del_nivel_anterior = false
	else:
		GameManager.iniciar_partida()
	$Pivote.visible = false
	var viene_del_gulag = GameManager.viene_del_gulag
	super()
	camara.global_position = jugador.global_position
	camara.reset_smoothing()
	if viene_del_gulag:
		get_tree().paused = false 
		return
	esperando_animacion = true
	$AnimationPlayer.play("Abrir_salir")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Abrir_salir":
		esperando_animacion = false
		get_tree().paused = false
		
	elif anim_name == "Animacion_final":
		esperando_animacion = false
		termino_nivel()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/boss_fight.tscn")
		
	else:
		super(anim_name)

func activar_animacion_final():
	animacion_final_iniciada = true
	GameManager.viene_del_nivel_anterior = true
	jugador.set_physics_process(false)
	$CanvasLayer/Barra_vida.visible = false
	var tween = create_tween()
	tween.tween_property(jugador, "global_position", Vector2(5559, 855), 1.5)
	await tween.finished
	$AnimationPlayer.play("Animacion_final")
