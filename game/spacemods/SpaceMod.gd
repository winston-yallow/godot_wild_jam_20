extends Area
class_name SpaceMod


# warning-ignore:unused_signal
signal finished()


export var associate := false
export var associated_pathway: NodePath

var error_already_pushed := false


func activate() -> void:
    pass


func on_player_left_area() -> void:
    pass


func get_up_vector(_transform: Transform, up: Vector3) -> Vector3:
    return up


func curve_matches(path: Pathway) -> bool:
    
    if not associate:
        return true
    
    if has_node(associated_pathway):
        return get_node(associated_pathway) == path
    elif not error_already_pushed:
        push_error('Associated pathway does not exist!')
    
    return false
