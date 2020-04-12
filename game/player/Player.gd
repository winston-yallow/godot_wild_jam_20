extends Spatial
class_name Player


export var speed := 8.0
export var drift := 2.0
export var smoothness := 6.0
export var lookahead := 3.0
export var first_path: NodePath = '.'

var direction := Vector3()
var smoothed_direction := Vector3()
var desired := Transform()
var possible_pathways := []
var offset := 0.0
var has_next := false
var next: Curve3D
var current: Curve3D

onready var path_detector: Area = $PathDetector


func _ready() -> void:
    
    # warning-ignore:return_value_discarded
    path_detector.connect('area_entered', self, '_on_pathway_entered')
    # warning-ignore:return_value_discarded
    path_detector.connect('area_exited', self, '_on_pathway_exited')
    
    desired = global_transform
    current = get_node(first_path).get_global_curve()
    offset = 0.0
    var ahead := _interpolate_offset(offset + lookahead, Vector3.UP)
    var start := _interpolate_offset(offset, Vector3.UP, true)
    look_at_from_position(start, ahead, Vector3.UP)


func _process(delta: float) -> void:
    
    direction = Vector3()
    direction.x += Input.get_action_strength('game_right') * drift
    direction.x -= Input.get_action_strength('game_left') * drift
    direction.y += Input.get_action_strength('game_up') * drift
    direction.y -= Input.get_action_strength('game_down') * drift
    if direction.length() >  drift:
        direction = direction.normalized() * drift
    direction = global_transform.basis.xform(direction)
    
    smoothed_direction = smoothed_direction.linear_interpolate(
        direction, delta * smoothness
    )
    
    offset += delta * speed
    var ahead := _interpolate_offset(offset + lookahead, direction)
    var start := _interpolate_offset(offset, direction, true)
    var up := Vector3.UP
    var pos = start + ((ahead - start) * 0.5)
    
    desired.origin = pos + smoothed_direction
    desired = desired.looking_at(ahead + smoothed_direction, up)
    
    global_transform = global_transform.interpolate_with(desired, delta * smoothness)


# warning-ignore:unused_argument
func _interpolate_offset(offs: float, direction: Vector3, make_current := false) -> Vector3:
    if not direction:
        direction = Vector3.FORWARD
    if offs >= current.get_baked_length():
        var remaining := offs - current.get_baked_length()
        if not has_next:
            if possible_pathways.size() == 0:
                push_error('Path ended without any possible continuations!')
                return current.interpolate_baked(current.get_baked_length())
            # TODO: Use actual logic to determine which path to choose
            next = _get_best_pathway(direction).get_global_curve()
            has_next = true
            possible_pathways.clear()
        if make_current:
            current = next
            offset = remaining
            has_next = false
        return next.interpolate_baked(remaining)
    else:
        return current.interpolate_baked(offs)


func _get_best_pathway(direction: Vector3) -> Pathway:
    var best := possible_pathways[0] as Pathway
    var best_angle := best.get_direction_vector().angle_to(direction)
    for pathway in possible_pathways:
        var angle := pathway.get_direction_vector().angle_to(direction) as float
        if angle < best_angle:
            best = pathway
            best_angle = angle
    return best


func _on_pathway_entered(other: Area):
    var parent = other.get_parent()
    if parent is Pathway:
        possible_pathways.append(parent)


func _on_pathway_exited(other: Area):
    var parent = other.get_parent()
    while parent in possible_pathways:
        possible_pathways.erase(parent)


func get_local_direction() -> Vector3:
    return global_transform.basis.xform_inv(direction)


func get_local_smoothed_direction() -> Vector3:
    return global_transform.basis.xform_inv(smoothed_direction)
