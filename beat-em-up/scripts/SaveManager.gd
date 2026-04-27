extends Node
class_name  SaveManager

var niveles = {
		"niveles_desbloqueados": 1
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cargar()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func guardar_niveles_desbloqueados():
	
	var archivo = FileAccess.open("user://save.json", FileAccess.WRITE)
	archivo.store_string(JSON.stringify(niveles))

func cargar():
	if not FileAccess.file_exists("user://save.json"):
		print("No existe archivo de guardado")
		return
	var archivo = FileAccess.open("user://save.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(archivo.get_as_text())
	if error == OK:
		print("Cargado: ", json.data)
		if json.data.has("niveles"):
			niveles = json.data["niveles"]
			niveles["niveles_desbloqueados"] = int(niveles["niveles_desbloqueados"])
			print("Niveles desbloqueados: ", niveles["niveles_desbloqueados"])
		if json.data.has("stats"):
			GameManager.stats = json.data["stats"]
			GameManager.contando_tiempo = false
	
func guardar_todo():
	var datos = {
		"niveles": niveles,
		"stats": {
			"dano_recibido": GameManager.stats["dano_recibido"],
			"dano_generado": GameManager.stats["dano_generado"],
			"vida_recuperada": GameManager.stats["vida_recuperada"],
			"enemigos_asesinados": GameManager.stats["enemigos_asesinados"],
			"fue_al_gulag": GameManager.stats["fue_al_gulag"],
			"tiempo": GameManager.stats["tiempo"]
		}
	}
	print("Guardando: ", datos)
	var archivo = FileAccess.open("user://save.json", FileAccess.WRITE)
	archivo.store_string(JSON.stringify(datos))
	print("Guardado en: ", ProjectSettings.globalize_path("user://save.json"))
