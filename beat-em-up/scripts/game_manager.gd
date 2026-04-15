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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func retry_level():
	resetear_gulag()
	var nivel_a_resetear = "res://scenes/nivel_" + str(GameManager.nivel_actual) + ".tscn"
	get_tree().change_scene_to_file(nivel_a_resetear)

func volver_al_nivel():
	viene_del_gulag = true
	var nivel_a_resetear = "res://scenes/nivel_" + str(GameManager.nivel_actual) + ".tscn"
	get_tree().change_scene_to_file(nivel_a_resetear)

func resetear_gulag():
	puede_ir_gulag = true
