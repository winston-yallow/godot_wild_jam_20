extends MultiMeshInstance


func _process(_delta: float) -> void:
    var bullets = get_tree().get_nodes_in_group('bullet')
    
    if bullets.size() > multimesh.instance_count:
        multimesh.instance_count = bullets.size() + 50
        multimesh.visible_instance_count = bullets.size()
        push_warning(
            'Not enough bullet instances. '
            + 'Automatically increased to ' + str(multimesh.instance_count)
        )
    else:
        multimesh.visible_instance_count = bullets.size()
    
    for idx in multimesh.visible_instance_count:
        multimesh.set_instance_transform(idx, bullets[idx].global_transform)
        multimesh.set_instance_color(idx, bullets[idx].color)
