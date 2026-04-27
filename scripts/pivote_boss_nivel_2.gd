extends Node2D

var animation_player : AnimationPlayer

func _ready() -> void:
	animation_player = get_parent().get_node("AnimationPlayerTemblor")
	
func run_slow():
	$AnimatedSprite2D.play("bat_run_slow")

func temblar_suave():
	animation_player.play("temblor_suave")
	
func temblar_medio():
	animation_player.play("temblor_medio")
	
func temblar_fuerte():
	animation_player.play("temblor_fuerte")

func idle():
	$AnimatedSprite2D.play("bat_idle")

func salto():
	$AnimatedSprite2D.play("bat_jump")
