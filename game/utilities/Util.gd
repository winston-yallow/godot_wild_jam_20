extends Object
class_name Util


static func to_global_curve(obj: Spatial, curve: Curve3D) -> Curve3D:
    var global_curve := Curve3D.new()
    for idx in curve.get_point_count():
        var point = curve.get_point_position(idx)
        var vec_in = curve.get_point_in(idx)
        var vec_out = curve.get_point_out(idx)
        global_curve.add_point(
            obj.to_global(point),
            obj.transform.basis.xform_inv(vec_in),
            obj.transform.basis.xform_inv(vec_out)
        )
    return global_curve
