extends Node2D

var vida_total = 700
var fase = 1
@onready var animation_player = $AnimationPlayer
var animacion_inicio_terminada = false

func _ready():
	$Boss_2.visible = false
	$Boss_2.process_mode = Node.PROCESS_MODE_DISABLED
	#$Boss_3.visible = false
	#$Boss_3.process_mode = Node.PROCESS_MODE_DISABLED
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
			$Boss_2.visible = false
			$Boss_2.process_mode = Node.PROCESS_MODE_DISABLED
			$Boss_3.visible = true
			$Boss_3.process_mode = Node.PROCESS_MODE_INHERIT
	
func boss_muerto():
	pass  # Hacer la animacion del boss muriendo o algo asi


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Entrar":
		animacion_inicio_terminada = true
