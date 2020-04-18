extends Area


export var stream: AudioStream

onready var audio: AudioStreamPlayer = $Audio


func _ready() -> void:
    # warning-ignore:return_value_discarded
    connect('body_entered', self, '_on_body_entered')
    audio.stream = stream


func _on_body_entered(other: Spatial):
    if other is Player and not audio.playing:
        audio.play(0.0)
