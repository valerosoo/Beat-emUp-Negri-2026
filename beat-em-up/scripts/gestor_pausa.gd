extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			get_parent().jugador.set_physics_process(true)
			get_parent().get_node("CanvasLayer/MenuPausa").visible = false
		else:
			get_tree().paused = true
			get_parent().jugador.set_physics_process(false)
			get_parent().get_node("CanvasLayer/MenuPausa").visible = true
