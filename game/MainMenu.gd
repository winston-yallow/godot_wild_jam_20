extends Control


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func load_tut() -> void:
    get_tree().change_scene("res://maps/Tutorial.tscn")


func load_mars() -> void:
    get_tree().change_scene("res://maps/GridMars.tscn")
