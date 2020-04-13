extends Control


export var player_path: NodePath = '.'
export var interpolation = 30.0
export var direction_radius := 40

var player: Player
var direction := Vector2()
var smoothed_direction := Vector2()
var direction_interpolated := Vector2()


func _ready() -> void:
    player = get_node(player_path)


func _process(delta: float) -> void:
    var direction3d := player.get_local_direction()
    direction = _to_vec2(direction3d) * direction_radius
    var smoothed_direction3d := player.get_local_smoothed_direction()
    smoothed_direction = _to_vec2(smoothed_direction3d) * direction_radius
    direction_interpolated = direction_interpolated.linear_interpolate(
        direction, delta * interpolation
    )
    update()


func _draw() -> void:
    var cam := get_tree().root.get_camera()
    var center := cam.unproject_position(player.to_global(player.nose))
    draw_arc(center, direction_radius, 0, TAU, 24, Color(0, 1.0, 0.7, 0.6), 1.0)
    draw_circle(center + smoothed_direction, 4, Color(0, 1.0, 0.7, 0.6))
    draw_circle(center + direction_interpolated, 2, Color(0, 1.0, 0.7, 0.9))


func _to_vec2(v: Vector3, flip_y := true) -> Vector2:
    return Vector2(v.x, -v.y if flip_y else v.y)
