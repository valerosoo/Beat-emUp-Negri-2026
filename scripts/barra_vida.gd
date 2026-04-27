extends Node2D

func _ready() -> void:
	await get_tree().process_frame
	var vida_max = GameManager.stats_jugador["vida_maxima"]
	$CanvasLayer/HealthUI/ProgressBar.max_value = vida_max
	$CanvasLayer/HealthUI/ProgressBar.value = vida_max 
