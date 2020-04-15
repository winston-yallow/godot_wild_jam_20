extends Area


export var laser_bullet_speed := 20.0
export var smoothness := 1.5

var active := false
var player: Player
var interpolated_velocity := Vector3()

onready var gun := $LaserGun
onready var target := $Target


func _ready() -> void:
    gun.target = target
    # warning-ignore:return_value_discarded
    connect('body_entered', self, '_on_body_entered')
    # warning-ignore:return_value_discarded
    connect('body_exited', self, '_on_body_exited')


func _process(delta: float) -> void:
    
    if not is_instance_valid(player):
        return
    
    interpolated_velocity = interpolated_velocity.linear_interpolate(
        player.velocity, delta * smoothness
    )
    if active:
        var dist := (player.global_transform.origin - global_transform.origin).length()
        var traveltime = dist / laser_bullet_speed
        var offset = interpolated_velocity * traveltime
        target.global_transform.origin = player.global_transform.origin + offset
    else:
        target.transform.origin = Vector3.FORWARD


func _on_body_entered(other: Spatial) -> void:
    if other is Player:
        player = other
        active = true
        gun.active = true


func _on_body_exited(other: Spatial) -> void:
    if other is Player:
        active = false
        gun.active = false
