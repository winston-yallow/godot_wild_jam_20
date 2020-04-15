extends Spatial


export(int, FLAGS, 'Player', 'Enemies', 'Obstacles') var collision_mask = 7

var harm := 0.2
var speed := 20
var lifetime := 2.0
var exclude := []
var lookahead := 1.5
var color := Color(1, 1, 1)


func _physics_process(delta: float) -> void:
    
    var movement := -global_transform.basis.z * speed * delta
    lifetime -= delta
    if lifetime < 0:
        queue_free()
    
    var space_state := get_world().direct_space_state
    var result := space_state.intersect_ray(
        global_transform.origin,
        global_transform.origin + (movement * lookahead),
        exclude,
        collision_mask,
        true,
        false
    )
    
    if result:
        if result.collider.has_method('damage'):
            result.collider.damage(harm)
        queue_free()
    
    global_transform.origin += movement
