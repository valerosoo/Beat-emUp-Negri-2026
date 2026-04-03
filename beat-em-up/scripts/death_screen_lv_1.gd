extends Node2D

var tiempo=10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	$Timer_L.text = str(tiempo)

func _on_timer_timeout() -> void:
	tiempo -= 1
	$Timer_L.text = str(tiempo)
	
	if tiempo <= 0:
		$Timer.stop()
		print("Game Over")
