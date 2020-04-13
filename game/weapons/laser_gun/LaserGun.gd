extends Spatial


var active := false
var cooldown := 0.1

var next_shot := cooldown

var target: Spatial
var targeting_pivot: Spatial
var emission_point: Spatial

var LaserBullet = preload('res://weapons/laser_gun/LaserBullet.tscn')


func _ready() -> void:
    targeting_pivot = $TargetingPivot
    emission_point = $TargetingPivot/EmissionPoint


func _process(delta: float) -> void:
    
    next_shot -= delta
    if next_shot <= 0:
        next_shot = cooldown
        var bullet = LaserBullet.instance()
        get_tree().current_scene.add_child(bullet)
        bullet.global_transform = emission_point.global_transform
        
    targeting_pivot.look_at(target.global_transform.origin, global_transform.basis.y)
