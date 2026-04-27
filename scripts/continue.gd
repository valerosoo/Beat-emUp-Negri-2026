extends Node2D

var tiempo=10
@onready var img = $Img_muerte

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var nivel = GameManager.nivel_actual
	var ruta = "res://assets/death_screens/death" + str(nivel) + ".png"
	
	img.texture = load(ruta)
	
	$Timer.start()
	$Timer_L.text = str(tiempo)

func _on_timer_timeout() -> void:
	tiempo -= 1
	$Timer_L.text = str(tiempo)
	
	if tiempo <= 0:
		$Timer.stop()
		ir_al_menu()


func _on_gulag_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gulag.tscn")


func _on_menu_pressed():
	ir_al_menu()

func ir_al_menu():
	GameManager.puede_ir_gulag = true
	GameManager.oleada_actual = 0
	GameManager.posicion_muerte = Vector2.ZERO
	GameManager.viene_del_gulag = false
	GameManager.resetear_stats()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
