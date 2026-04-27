extends Control
class_name  TextoTemblor

var tiempo = 0
var base_pos

func _ready():
	base_pos = position

func _process(delta):
	tiempo += delta * 20
	position = base_pos + Vector2(
		sin(tiempo) * 3,
		cos(tiempo * 1.5) * 2
	)
