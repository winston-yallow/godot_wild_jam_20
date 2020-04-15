extends KinematicBody
class_name Player


export var speed := 8.0
export var drift := 2.0
export var smoothness := 6.0
export var lookahead := 3.0
export var first_path: NodePath = '.'
export var nose := Vector3.FORWARD

var direction := Vector3()
var smoothed_direction := Vector3()
var desired := Transform()
var possible_pathways := []
var possible_spacemods := []
var offset := 0.0
var has_next := false
var next: Curve3D
var next_pathway: Pathway
var current: Curve3D
var current_pathway: Pathway
var up := Vector3.UP
var health := 100.0
var velocity := Vector3()

var active_spacemod  # No type to make this nullable

onready var path_detector: Area = $PathDetector
onready var lg_left = $LaserGunLeft
onready var lg_right = $LaserGunRight
onready var target = $Target
onready var target_left = $Target/TargetLeft
onready var target_right = $Target/TargetRight


func _ready() -> void:
    
    # warning-ignore:return_value_discarded
    path_detector.connect('area_entered', self, '_on_area_entered')
    # warning-ignore:return_value_discarded
    path_detector.connect('area_exited', self, '_on_area_exited')
    
    lg_left.target = target_left
    lg_right.target = target_right
    
    desired = global_transform
    current_pathway = get_node(first_path)
    current = current_pathway.get_global_curve()
    offset = 0.0
    var ahead := _interpolate_offset(offset + lookahead, Vector3.UP)
    var start := _interpolate_offset(offset, Vector3.UP, true)
    look_at_from_position(start, ahead, Vector3.UP)


func _input(event: InputEvent) -> void:
    if event.is_action_pressed('weapon_primary'):
        lg_left.active = true
        lg_right.active = true
    elif event.is_action_released('weapon_primary'):
        lg_left.active = false
        lg_right.active = false


func _physics_process(delta: float) -> void:
    
    direction = Vector3()
    direction.x += Input.get_action_strength('game_right') * drift
    direction.x -= Input.get_action_strength('game_left') * drift
    direction.y += Input.get_action_strength('game_up') * drift
    direction.y -= Input.get_action_strength('game_down') * drift
    if direction.length() >  drift:
        direction = direction.normalized() * drift
    direction = global_transform.basis.xform(direction)
    
    smoothed_direction = smoothed_direction.linear_interpolate(
        direction, delta * smoothness
    )
    
    var offset_change = delta * speed
    var desired_offset = offset + offset_change
    var ahead := _interpolate_offset(desired_offset + lookahead, direction)
    var start := _interpolate_offset(desired_offset, direction, true)
    var pos = start + ((ahead - start) * 0.5)
    
    if active_spacemod:
        up = active_spacemod.get_up_vector(pos, up)
    
    desired.origin = pos + smoothed_direction
    desired = desired.looking_at(ahead + smoothed_direction, up)
    var new_transform := global_transform.interpolate_with(desired, delta * smoothness)
    velocity = (new_transform.origin - global_transform.origin) / delta
    
    var remaining_velo := move_and_slide(velocity)
    global_transform.basis = new_transform.basis
    
    var f: float
    var local_velo := global_transform.basis.xform_inv(velocity)
    var local_remaining := global_transform.basis.xform_inv(remaining_velo)
    if local_velo.z != 0:
        f = clamp(local_remaining.z / local_velo.z, 0.0, 1.0)
    else:
        f = 0
    
    offset += offset_change * f
    
    lg_left.speed_boost = speed * f
    lg_right.speed_boost = speed * f
    
    # TODO: decided based on remaining velo if damage should be applied
    # and if the player must be reset/freezed


# warning-ignore:unused_argument
func _interpolate_offset(offs: float, dir: Vector3, make_current := false) -> Vector3:
    if not dir:
        dir = Vector3.FORWARD
    if offs >= current.get_baked_length():
        var remaining := offs - current.get_baked_length()
        if not has_next:
            if possible_pathways.size() == 0:
                push_error('Path ended without any possible continuations!')
                return current.interpolate_baked(current.get_baked_length())
            # TODO: Use actual logic to determine which path to choose
            next_pathway = _get_best_pathway(dir)
            next = next_pathway.get_global_curve()
            has_next = true
            possible_pathways.clear()
        if make_current:
            current_pathway = next_pathway
            current = next
            offset = remaining
            has_next = false
            _recheck_possible_spacemods()
        return next.interpolate_baked(remaining)
    else:
        return current.interpolate_baked(offs)


func _get_best_pathway(dir: Vector3) -> Pathway:
    var best := possible_pathways[0] as Pathway
    var best_angle := best.get_direction_vector().angle_to(dir)
    for pathway in possible_pathways:
        var angle := pathway.get_direction_vector().angle_to(dir) as float
        if angle < best_angle:
            best = pathway
            best_angle = angle
    return best


func _recheck_possible_spacemods() -> void:
    var idx = 0
    while idx < possible_spacemods.size():
        var mod = possible_spacemods[idx]
        if mod.curve_matches(current_pathway):
            _set_spacemod(mod)
            return
        idx += 1


func _set_spacemod(mod: SpaceMod) -> void:
    if active_spacemod:
        push_warning('Forced spacemode replacement: ' + mod.name)
        if active_spacemod.is_connected('finished', self, '_unset_spacemod'):
            active_spacemod.disconnect('finished', self, '_unset_spacemod')
    active_spacemod = mod
    active_spacemod.activate()
    active_spacemod.connect('finished', self, '_unset_spacemod', [], CONNECT_ONESHOT)


func _unset_spacemod() -> void:
    active_spacemod = null


func _on_area_entered(other: Area) -> void:
    
    # Check for space mods
    if other is SpaceMod:
        if other.curve_matches(current_pathway):
            _set_spacemod(other)
        else:
            possible_spacemods.append(other)
    
    # Check for pathways
    var parent = other.get_parent()
    if parent is Pathway:
        possible_pathways.append(parent)


func _on_area_exited(other: Area) -> void:
    
    # Notify active spacemod
    if other == active_spacemod:
        active_spacemod.on_player_left_area()
    
    # Remove possible space mods
    while other in possible_spacemods:
        possible_spacemods.erase(other)
    
    # Remove possible pathways
    var parent = other.get_parent()
    while parent in possible_pathways:
        possible_pathways.erase(parent)


func get_local_direction() -> Vector3:
    return global_transform.basis.xform_inv(direction) / drift


func get_local_smoothed_direction() -> Vector3:
    return global_transform.basis.xform_inv(smoothed_direction) / drift


func heal(amount: float) -> void:
    health = clamp(health + amount, 0, 100)


func damage(amount: float) -> void:
    health = clamp(health - amount, 0, 100)
