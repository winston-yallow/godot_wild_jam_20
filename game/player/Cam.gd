extends Spatial


export var speed := 8.0
export var target_path := NodePath('.')
export var max_angle := 0.5

var target: Spatial
var pivot: Position3D


func _ready() -> void:
    set_as_toplevel(true)
    target = get_node(target_path)
    pivot = $Pivot


func _process(delta: float) -> void:
    
    transform = transform.interpolate_with(
        target.global_transform,
        delta * speed
    )
    
    var look := Vector3()
    look.y += Input.get_action_strength('look_left')
    look.y -= Input.get_action_strength('look_right')
    look.x += Input.get_action_strength('look_up')
    look.x -= Input.get_action_strength('look_down')
    
    if look.length() > 1:
        look = look.normalized()
    
    look *= max_angle
    
    pivot.rotation = pivot.rotation.linear_interpolate(look, delta * speed)
