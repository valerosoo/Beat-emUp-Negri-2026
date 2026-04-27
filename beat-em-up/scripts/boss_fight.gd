extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var game_over = $CanvasLayer/GameOver

@export var num_nivel = 3

var animacion_inicio_terminada = false
var vida_total = 700
var fase = 1

func _ready():
	GameManager.nivel_actual = num_nivel
	GameManager.puede_ir_gulag = false
	if GameManager.viene_del_nivel_anterior:
		GameManager.continuar_siguiente_nivel()
		GameManager.viene_del_nivel_anterior = false
	else:
		GameManager.iniciar_partida()
	$CanvasLayer/Victoria.visible = false
	$CanvasLayer/MenuPausa.visible = false
	$Boss_2.visible = false
	$Boss_2.process_mode = Node.PROCESS_MODE_DISABLED
	$Boss_3.visible = false
	$Boss_3.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().get_first_node_in_group("Barra_boss").max_value = vida_total
	animation_player.play("Entrar")
	pass
	
func restar_vida_boss(dano):
	vida_total -= dano
	get_tree().get_first_node_in_group("Barra_boss").value = vida_total
	
	if vida_total <= 467 and fase == 1:
		fase = 2
		cambiar_fase()
	elif vida_total <= 233 and fase == 2:
		fase = 3
		cambiar_fase()
	elif vida_total <= 0:
		boss_muerto()
	
func cambiar_fase():
	match fase:
		2:
			$Boss_1.desactivar()
			$Boss_1.visible = false
			$Boss_1.process_mode = Node.PROCESS_MODE_DISABLED
			$Boss_2.visible = true
			$Boss_2.process_mode = Node.PROCESS_MODE_INHERIT
			$Boss_2.elegir_ataque.call_deferred()
		3:
			$Boss_2.desactivar()
			$Boss_2.visible = false
			$Boss_2.process_mode = Node.PROCESS_MODE_DISABLED
			$Boss_3.visible = true
			$Boss_3.barrera.set_deferred("disabled", true)
			$Boss_3.barrera_sprite.visible = false
			$Boss_3.process_mode = Node.PROCESS_MODE_INHERIT
			$Boss_3.elegir_ataque.call_deferred()
	
func boss_muerto():
	$Boss_3.desactivar()
	$Boss_3.visible = false
	$Boss_3.process_mode = Node.PROCESS_MODE_DISABLED
	$CanvasLayer/Victoria.mostrar_stats()
	$CanvasLayer/Victoria.visible = true
	get_tree().paused = true
	pass  # Hacer la animacion del boss muriendo o algo asi


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Entrar":
		animacion_inicio_terminada = true

func mostrar_death_screen():
	game_over.mostrar_stats()
	game_over.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var menu_pausa = get_tree().get_root().find_child("MenuPausa", true, false)
		if get_tree().paused:
			get_tree().paused = false
			get_tree().get_first_node_in_group("jugador").set_physics_process(true)
			if menu_pausa:
				menu_pausa.visible = false
		else:
			get_tree().paused = true
			get_tree().get_first_node_in_group("jugador").set_physics_process(false)
			if menu_pausa:
				menu_pausa.visible = true
