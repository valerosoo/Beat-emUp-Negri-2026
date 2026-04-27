extends Node2D

@onready var sonido = $GameOverSound

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_set_process_always(self)
	$Menu.pressed.connect(_on_menu_pressed)
	$Retry.pressed.connect(_on_retry_pressed)

func _set_process_always(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in node.get_children():
		_set_process_always(child)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.resetear_gulag()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.retry_level()
	
func mostrar_stats():
	await get_tree().process_frame
	var menu_btn = $Menu
	sonido.play()
	GameManager.contando_tiempo = false
	$VBoxContainer/DanoRecibido.text = "Daño recibido: " + str(GameManager.stats["dano_recibido"])
	$VBoxContainer/DanoGenerado.text = "Daño generado: " + str(GameManager.stats["dano_generado"])
	$VBoxContainer/VidaRecuperada.text = "Vida recuperada: " + str(GameManager.stats["vida_recuperada"])
	$VBoxContainer/Enemigos.text = "Enemigos eliminados: " + str(GameManager.stats["enemigos_asesinados"])
	if GameManager.stats["fue_al_gulag"]:
		$VBoxContainer/Gulag.text = "Fue al gulag: Sí"
	else:
		$VBoxContainer/Gulag.text = "Fue al gulag: No"
	$VBoxContainer/Tiempo.text = "Tiempo: " + GameManager.tiempo_formateado()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if $Menu.get_global_rect().has_point(event.position):
			print("forzando menu")
			_on_menu_pressed()
		if $Retry.get_global_rect().has_point(event.position):
			print("forzando retry")
			_on_retry_pressed()
