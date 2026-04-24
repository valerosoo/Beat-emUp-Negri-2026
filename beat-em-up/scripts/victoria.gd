extends Node2D

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func mostrar_stats():
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
