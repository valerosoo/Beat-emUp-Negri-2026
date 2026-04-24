extends Node
class_name GameManagerCN

var stats_jugador
var nivel_actual = 1
var gulag = {
	"enemigo":null,
	"buff":1.5
}
var puede_ir_gulag = true
var viene_del_gulag = false
var oleada_actual = 0
var posicion_muerte = Vector2.ZERO

var stats = {
	"dano_recibido": 0,
	"dano_generado": 0,
	"vida_recuperada": 0,
	"enemigos_asesinados": 0,
	"fue_al_gulag": false,
	"tiempo": 0.0
}
var contando_tiempo = false
var viene_del_nivel_anterior = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if contando_tiempo:
		stats["tiempo"] += delta

func retry_level():
	resetear_gulag()
	var nivel_a_resetear = "res://scenes/nivel_" + str(GameManager.nivel_actual) + ".tscn"
	get_tree().change_scene_to_file(nivel_a_resetear)

func volver_al_nivel():
	viene_del_gulag = true
	registrar_gulag()
	var nivel_a_resetear = "res://scenes/nivel_" + str(GameManager.nivel_actual) + ".tscn"
	get_tree().change_scene_to_file(nivel_a_resetear)

func resetear_gulag():
	puede_ir_gulag = true
	
func iniciar_partida():
	resetear_stats()
	contando_tiempo = true
	
func continuar_siguiente_nivel():
	contando_tiempo = true

func resetear_stats():
	stats = {
		"dano_recibido": 0,
		"dano_generado": 0,
		"vida_recuperada": 0,
		"enemigos_asesinados": 0,
		"fue_al_gulag": false,
		"tiempo": 0.0
	}

func registrar_dano_recibido(dano):
	stats["dano_recibido"] += dano
	
func registrar_dano_generado(dano):
	stats["dano_generado"] += dano
	
func registrar_vida_recuperada(cantidad):
	stats["vida_recuperada"] += cantidad
	
func registrar_enemigo_asesinado():
	stats["enemigos_asesinados"] += 1
	
func registrar_gulag():
	stats["fue_al_gulag"] = true

func tiempo_formateado() -> String:
	var segundos = int(stats["tiempo"]) % 60
	var minutos = int(stats["tiempo"]) / 60
	return "%02d:%02d" % [minutos, segundos]
