tool
extends Path
class_name Pathway


export(float, -180, 180) var degree := 0.0 setget _set_degree, _get_degree
export var only_forward := false setget _set_only_forward
var _selection_rotation := 0.0
var _global_curve_cache: Curve3D

func _ready() -> void:
    curve.up_vector_enabled = true
    # warning-ignore:return_value_discarded
    connect('curve_changed', self, '_update_start_location')
    _update_start_location()
    $Pivot/Indicator.visible = Engine.editor_hint or get_tree().debug_collisions_hint


func get_desired_rotation() -> float:
    return _selection_rotation


func get_direction_vector() -> Vector3:
    return $Pivot.global_transform.basis.y


func get_global_curve() -> Curve3D:
    if _global_curve_cache:
        return _global_curve_cache
    var global_curve := Curve3D.new()
    for idx in curve.get_point_count():
        var point = curve.get_point_position(idx)
        var vec_in = curve.get_point_in(idx)
        var vec_out = curve.get_point_out(idx)
        global_curve.add_point(
            to_global(point),
            transform.basis.xform_inv(vec_in),
            transform.basis.xform_inv(vec_out)
        )
    _global_curve_cache = global_curve
    return global_curve


func _update_start_location():
    if is_inside_tree() and curve.get_point_count() > 1:
        var start := to_global(curve.interpolate_baked(0.0))
        var next := to_global(curve.interpolate_baked(0.5))
        var up := transform.basis.xform_inv(curve.interpolate_baked_up_vector(0.0))
        if has_node('Pivot'):
            var forward = next - start
            var right = up.cross(forward)
            if only_forward:
                $Pivot.global_transform = Transform(
                    Basis(
                        right.normalized(),
                        forward.normalized(),
                        up.normalized()
                    ),
                    start
                )
            else:
                $Pivot.global_transform = Transform(
                    Basis(
                        right.normalized(),
                        up.normalized(),
                        forward.normalized()
                    ).rotated(-forward.normalized(), get_desired_rotation()),
                    start
                )
        if has_node('Area'):
            $Area.global_transform.origin = start


func _set_degree(new_value: float) -> void:
    degree = new_value
    _selection_rotation = deg2rad(new_value)
    _update_start_location()


func _get_degree() -> float:
    return rad2deg(_selection_rotation)


func _set_only_forward(new_value: bool) -> void:
    only_forward = new_value
    _update_start_location()
