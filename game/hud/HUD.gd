extends Control


export var player_path: NodePath = '.'
export var interpolation = 30.0

var player: Player
var direction := Vector2()
var smoothed_direction := Vector2()
var direction_interpolated := Vector2()


func _ready() -> void:
    player = get_node(player_path)


func _process(delta: float) -> void:
    var direction3d := player.get_local_direction()
    direction = Vector2(direction3d.x, -direction3d.y) * 20
    var smoothed_direction3d := player.get_local_smoothed_direction()
    smoothed_direction = Vector2(smoothed_direction3d.x, -smoothed_direction3d.y) * 20
    direction_interpolated = direction_interpolated.linear_interpolate(
        direction, delta * interpolation
    )
    update()


func _draw() -> void:
    var cam := get_tree().root.get_camera()
    var center := cam.unproject_position(player.to_global(player.nose))
    draw_arc(center, 40, 0, TAU, 24, Color(0, 1.0, 0.7, 0.6), 1.0)
    draw_circle(center + smoothed_direction, 4, Color(0, 1.0, 0.7, 0.6))
    draw_circle(center + direction_interpolated, 2, Color(0, 1.0, 0.7, 0.9))
