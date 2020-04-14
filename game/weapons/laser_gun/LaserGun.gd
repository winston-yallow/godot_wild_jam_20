extends Spatial


export(int, FLAGS, 'Player', 'Enemies', 'Obstacles') var collision_mask = 0
export var material: Material
export var check_visibility := true
export var speed_boost := 0.0

var active := false
var cooldown := 0.1
var exclude := []

var next_shot := cooldown

var target: Spatial
var targeting_pivot: Spatial
var emission_point: Spatial

const LaserBullet = preload('res://weapons/laser_gun/LaserBullet.tscn')


func _ready() -> void:
    targeting_pivot = $TargetingPivot
    emission_point = $TargetingPivot/EmissionPoint


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
            exclude,
            collision_mask
        )
        if result and result.collider != target:
            return
    
    var bullet = LaserBullet.instance()
    get_tree().current_scene.add_child(bullet)
    bullet.global_transform = emission_point.global_transform
    bullet.collision_mask = collision_mask
    bullet.exclude = exclude
    bullet.speed += speed_boost
    bullet.set_material(material)
