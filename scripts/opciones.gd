extends Node2D

var esperando_input = false
var accion_a_reasignar = ""

func _ready() -> void:
	var slider = $HSlider
	var track_bg = StyleBoxFlat.new()
	track_bg.bg_color = Color("#3a2e1a")
	track_bg.set_corner_radius_all(5)
	track_bg.content_margin_top = 5
	track_bg.content_margin_bottom = 5
	slider.add_theme_stylebox_override("slider", track_bg)
	var track_fill = StyleBoxFlat.new()
	track_fill.bg_color = Color("#ba841b")
	track_fill.set_corner_radius_all(5)
	track_fill.content_margin_top = 5
	track_fill.content_margin_bottom = 5
	slider.add_theme_stylebox_override("grabber_area", track_fill)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))
	ManejadorGuardado.guardar_todo()

func _on_menu_pressed() -> void:
	GameManager.sonido_menu_select()
	if GameManager.viene_del_menu:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		get_parent().get_node("Control").visible = true
		visible = false


func _on_shift_pressed() -> void:
	pass # Replace with function body.


func _on_w_pressed() -> void:
	pass # Replace with function body.


func _on_s_pressed() -> void:
	pass # Replace with function body.


func _on_a_pressed() -> void:
	pass # Replace with function body.


func _on_d_pressed() -> void:
	pass # Replace with function body.


func _on_spacebar_pressed() -> void:
	pass # Replace with function body.


func _on_leftclick_pressed() -> void:
	pass # Replace with function body.


func _on_rightclick_pressed() -> void:
	pass # Replace with function body.
