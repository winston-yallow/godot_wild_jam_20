extends Control


func _ready() -> void:
    visible = false


func _input(event: InputEvent) -> void:
    if event.is_action_pressed('game_pause'):
        if get_tree().paused:
            resume()
        else:
            pause()


func _on_exit_pressed() -> void:
    get_tree().quit()


func _on_main_menu_pressed() -> void:
    resume()
    get_tree().change_scene("res://MainMenu.tscn")


func _on_resume_pressed() -> void:
    resume()


func pause():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().paused = true
    visible = true


func resume():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    get_tree().paused = false
    visible = false
