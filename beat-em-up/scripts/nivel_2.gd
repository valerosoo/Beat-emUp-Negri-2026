extends Nivel1

func _ready() -> void:
	super()
	esperando_animacion = true
	$AnimationPlayer.play("Abrir_salir")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Abrir_salir":
		esperando_animacion = false
		get_tree().paused = false
	else:
		super(anim_name)
