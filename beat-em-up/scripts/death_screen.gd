extends Node2D


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_retry_pressed() -> void:
	GameManager.retry_level()
	
