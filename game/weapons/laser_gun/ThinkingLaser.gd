extends Area


export var laser_bullet_speed := 20.0
export var smoothness := 1.5
export var cooldown := 0.23

var active := false
var player: Player
var interpolated_velocity := Vector3()

onready var next_recalc := cooldown
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
        (player.velocity * player.movement_factor), delta * smoothness
    )
    
    if not active:
        target.transform.origin = Vector3.FORWARD
    elif next_recalc <= 0:
        _recalc_target_pos()
        next_recalc = cooldown
    else:
        next_recalc -= delta


func _recalc_target_pos() -> void:
    var dist := (player.global_transform.origin - global_transform.origin).length()
    var traveltime = dist / laser_bullet_speed
    var offset = interpolated_velocity * (traveltime + (cooldown * 0.75))
    target.global_transform.origin = player.global_transform.origin + offset


func _on_body_entered(other: Spatial) -> void:
    if other is Player:
        player = other
        active = true
        gun.active = true


func _on_body_exited(other: Spatial) -> void:
    if other is Player:
        active = false
        gun.active = false
