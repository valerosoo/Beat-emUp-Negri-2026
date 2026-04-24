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
		return
	var archivo = FileAccess.open("user://save.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(archivo.get_as_text())
	if error == OK:
		if json.data.has("niveles"):
			niveles = json.data["niveles"]
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
	var archivo = FileAccess.open("user://save.json", FileAccess.WRITE)
	archivo.store_string(JSON.stringify(datos))
