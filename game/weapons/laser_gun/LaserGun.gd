extends Spatial


export(int, FLAGS, 'Player', 'Enemies', 'Obstacles') var collision_mask = 0
export var color := Color(1, 1, 1)
export var check_visibility := true
export var speed_boost := 0.0
export var auto_exclude: NodePath
export var audio_restart := 0.07

var active := false
var cooldown := 0.1
var exclude_gun := []
var exclude_bullet := []

var next_shot := cooldown

var target: Spatial
var targeting_pivot: Spatial
var emission_point: Spatial
var audio: AudioStreamPlayer3D

const LaserBullet = preload('res://weapons/laser_gun/LaserBullet.tscn')


func _ready() -> void:
    targeting_pivot = $TargetingPivot
    emission_point = $TargetingPivot/EmissionPoint
    audio = $AudioStreamPlayer3D
    if auto_exclude and has_node(auto_exclude):
        exclude_gun.append(get_node(auto_exclude))


func _process(delta: float) -> void:
    
    if not active or not is_instance_valid(target):
        return
    
    next_shot -= delta
        
    targeting_pivot.look_at(target.global_transform.origin, global_transform.basis.y)
    
    if next_shot <= 0:
        next_shot = cooldown
        _try_shooting()


func _try_shooting() -> void:
    
    if check_visibility:
        var space_state := get_world().direct_space_state
        var result := space_state.intersect_ray(
            emission_point.global_transform.origin,
            target.global_transform.origin,
            exclude_gun,
            collision_mask
        )
        if result and result.collider != target:
            return
    
    audio.play(0.0)
    var bullet = LaserBullet.instance()
    get_tree().current_scene.add_child(bullet)
    bullet.global_transform = emission_point.global_transform
    bullet.collision_mask = collision_mask
    bullet.exclude = exclude_bullet
    bullet.color = color
    bullet.speed += speed_boost
