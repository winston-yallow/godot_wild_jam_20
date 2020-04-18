extends Spatial


export var speed := 8.0
export var target_path := NodePath('.')
export var max_angle := 0.7
export var mouse_threshold := 0.3
export var mouse_sensitivity := 0.01

var mouse_preferred := true
var mouse_axis := Vector3()

var target: Spatial
var pivot: Position3D


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    set_as_toplevel(true)
    target = get_node(target_path)
    pivot = $Pivot


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_vector = event.relative * mouse_sensitivity
        mouse_axis -= Vector3(mouse_vector.y, mouse_vector.x, 0)
        if not mouse_preferred and mouse_axis.length() > mouse_threshold:
            mouse_preferred = true
        if mouse_axis.length() > 1:
            mouse_axis = mouse_axis.normalized()


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
    
    if look.length() > 0:
        mouse_preferred = false
    
    if mouse_preferred:
        look = mouse_axis
    elif look.length() > 1:
        look = look.normalized()
    
    look *= max_angle
    
    pivot.rotation = pivot.rotation.linear_interpolate(look, delta * speed)
