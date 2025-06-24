@icon("res://soundtexicon.png")
class_name SoundTexture extends Resource
@export var ingame_name : String
@export_group("Audio properties")
@export var footsteps : AudioStream
@export_range(0.0, 2.0) var footstep_loudness_linear : float = 0.8
@export var footsteps_running : AudioStream
@export_range(0.0, 2.0) var footstep_running_loudness_linear : float = 0.8
@export var landing : AudioStream
@export_range(0.0, 2.0) var landing_loudness_linear : float = 0.8
@export var slide : AudioStream
@export_range(0.0, 2.0) var slide_loudness_linear : float = 0.8
@export var wallrun : AudioStream
@export_range(0.0, 2.0) var wallrun_loudness_linear : float = 0.8
@export var roll : AudioStream
@export_range(0.0, 2.0) var roll_loudness_linear : float = 0.8
@export_group("Optional physics properties")
@export var physics_sounds: AudioStream
@export var treshold_in_joules: AudioStream
@export_group("Accessibility")
@export var subtitles: Array[String]
