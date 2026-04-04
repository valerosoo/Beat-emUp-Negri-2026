extends Node
class_name  SaveManager

var niveles = {
		"niveles_desbloqueados": 1
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	var contenido = archivo.get_as_text()
	var json = JSON.new()
	var error = json.parse(contenido)
	
	if error == OK:
		niveles = json.data
