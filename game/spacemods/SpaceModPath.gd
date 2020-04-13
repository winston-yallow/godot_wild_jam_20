extends SpaceMod


export var target_path: NodePath
export var safe_ending := 1.0
export var end_delay := -1.0
export var end_vec := Vector3.UP

var end_start_up := Vector3.UP
var end_phase := false
var end_time := 0.0
var curve: Curve3D


func _ready() -> void:
    var path_node = get_node(target_path)
    curve = Util.to_global_curve(path_node, path_node.curve)


func activate() -> void:
    end_phase = false


func _process(delta: float) -> void:
    if end_phase:
        end_time -= delta


func get_up_vector(pos: Vector3, _up: Vector3) -> Vector3:
    
    if end_phase:
        if end_time <= 0:
            emit_signal('finished')
            end_phase = false
            return end_vec
        var f = end_time / end_delay
        return end_start_up.linear_interpolate(end_vec, f)
    
    var closest_offset := curve.get_closest_offset(pos)
    var closest_point := curve.interpolate_baked(closest_offset)
    var remaining := curve.get_baked_length() - closest_offset
    var new_up := (closest_point - pos).normalized()
    
    if remaining < safe_ending:
        end_phase = true
        if end_delay == 0:
            emit_signal('finished')
            return end_vec
        elif end_delay == -1:
            emit_signal('finished')
        else:
            end_phase = true
            end_time = end_delay
            end_start_up = new_up
    
    return new_up
