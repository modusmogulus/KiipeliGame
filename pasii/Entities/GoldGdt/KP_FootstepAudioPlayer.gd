extends Node3D
@export var AudioPlayer: AudioStreamPlayer3D
@export var Groundcast: RayCast3D
@export var MaterialCamera: Camera3D
@export var MaterialViewportTexture : ViewportTexture
@export var DefaultSoundTexture : SoundTexture
var standing_on : PhysicsBody3D
var current_sound_tex : SoundTexture
var original_loudness
var auralization_count : int
var echo_players : Array[AudioStreamPlayer3D]
var echo_wait_times : Array[float]
@export var player_hull : CollisionShape3D
@export var rays : int = 128
@export_range(0.0, 1.0) var reflection_probability : float = 0.8
@export var max_reflection_octaves = 2

func _ready():
	original_loudness = AudioPlayer.volume_linear
	for i in rays:
		var ep = AudioPlayer.duplicate()
		#ep.bus = "RTReverb"
		add_child(ep)
		echo_players.append(ep)
		echo_wait_times.append(-1.0)

func _reset_echo_players():
	for i in echo_players.size():
		if echo_players[i].playing == true: return
		if echo_wait_times[i] > -1.0 && echo_wait_times[i] <= 0.0:
			echo_wait_times[i] = -1.0
			
func _random_dir() -> Vector3:
	var rx = randf_range(-1, 1)
	var ry = randf_range(0.0, 0.1) #disk trace
	var rz = randf_range(-1, 1)
	var dir = Vector3(rx, ry, rz)
	return Vector3(rx, ry, rz)
	
func get_room_size() -> float:
	var average: float = 0.0
	for i in echo_wait_times.size():
		if echo_wait_times[i] > 0:
			average += echo_wait_times[i]
	average = average/(echo_wait_times.size()-1)
	return average
func play_auralized(start_pos : Vector3, refl_index : int):
	_reset_echo_players()
	var space_state = get_world_3d().direct_space_state
	if refl_index == 0:
		for ep in echo_players:
			if ep.stream != AudioPlayer.stream:
				ep.stream = AudioPlayer.stream
			ep.volume_db = AudioPlayer.volume_db + 12.0
			ep.max_db = AudioPlayer.volume_db -6.0
			ep.unit_size = 10
			ep.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
			ep.panning_strength = 1.0
			ep.playing = false
			ep.max_polyphony = 8
			ep.attenuation_filter_cutoff_hz = 40
			ep.attenuation_filter_db = -3
			ep.pitch_scale = AudioPlayer.pitch_scale
			ep.bus = "RTReverb"
		AudioPlayer.play()
	for i in echo_players.size():
		if echo_wait_times[i] > 0.0 or echo_players[i].playing: return
		echo_players[i].volume_linear *= refl_index+1
		
		var dir = _random_dir()
		var query = PhysicsRayQueryParameters3D.create(global_position + dir*1.2, global_position+dir*1000)
		query.exclude = [player_hull]
		var result = space_state.intersect_ray(query)
		if result:
			#print(result)
			var travel : Vector3 = result.position - global_position
			
			#print(travel.length())
			if refl_index < max_reflection_octaves:
				if reflection_probability < randf_range(0.0, 1.0):
					play_auralized(result.position, refl_index+1)
				else:
					echo_players[i].global_position = global_position + travel*2
					echo_wait_times[i] = (1*(2*travel.length())/343.0)*(refl_index+1)
					#echo_players[i].pitch_scale = echo_players[i].pitch_scale - echo_wait_times[i]
		#print("ROOM SIZE: " + str(get_room_size()))
func getMaterial() -> Color:
	var image = MaterialViewportTexture.get_image()
	var pixel_0_0 = image.get_pixel(0, 0)
	return pixel_0_0

func playFootstepSound():
	Groundcast.force_raycast_update()
	if Groundcast.get_collider():
		
		var col = Groundcast.get_collider()
		if col == PhysicsBody3D:
			standing_on = col #For debug ui
		#print(col)
		#HOW TO USE: ADD A SOUND MATERIAL NODE UNDER EVERY STATIC BODY... 
		for child in col.get_children():
			if child is SoundMaterial:
				if child.sound_texture.footsteps != AudioPlayer:
					current_sound_tex = child.sound_texture
					if AudioPlayer.stream != current_sound_tex.footsteps:
						AudioPlayer.stream = current_sound_tex.footsteps
					AudioPlayer.volume_linear = original_loudness * child.sound_texture.footstep_loudness_linear
					#AudioPlayer.play()
					play_auralized(global_position, 0)
			else:
				current_sound_tex = DefaultSoundTexture
				if AudioPlayer.stream != current_sound_tex.footsteps:
					AudioPlayer.stream = current_sound_tex.footsteps
				AudioPlayer.volume_linear = DefaultSoundTexture.footstep_loudness_linear * original_loudness
				#AudioPlayer.play()
				play_auralized(global_position, 0)
		#var gr = col.get_groups()
		#print(getMaterial())
		#if AudioManager.SoundPassMappings.find_key(getMaterial()):
		#	AudioPlayer.stream = AudioManager.SoundPassMappings.find_key(getMaterial())
		#	print(AudioManager.SoundPassMappings.find_key(getMaterial()))
			#AudioPlayer.play()

func playLandingSound():
	Groundcast.force_raycast_update()
	if Groundcast.get_collider():
		
		var col = Groundcast.get_collider()

		for child in col.get_children():
			if child is SoundMaterial:
				if child.sound_texture.landing != AudioPlayer:
					current_sound_tex = child.sound_texture
					AudioPlayer.stream = current_sound_tex.landing
					AudioPlayer.volume_linear = original_loudness * child.sound_texture.landing_loudness_linear
					play_auralized(global_position, 0)
			else:
				current_sound_tex = DefaultSoundTexture
				AudioPlayer.stream = current_sound_tex.landing
				AudioPlayer.volume_linear = DefaultSoundTexture.landing_loudness_linear * original_loudness
				play_auralized(global_position, 0)


func _process(delta: float) -> void:
	MaterialCamera.global_position = global_position
	#MaterialCamera.global_rotation = global_rotation
	#MaterialCamera.global_basis = global_basis
var counter : int = 0
func _physics_process(delta: float) -> void:
	counter += 1
	if counter >= 10:
		counter = 0
		#AudioServer.get_bus_effect(4,1).room_size = get_room_size()*10
		
	for i in echo_wait_times.size():
		if echo_wait_times[i] > 0.0:
			echo_wait_times[i] -= delta
		#else:
		if echo_wait_times[i] <= 0.0 && echo_wait_times[i] > -1.0:
			AudioServer.get_bus_effect(5,1).room_size = lerp(AudioServer.get_bus_effect(5,1).room_size, echo_wait_times[i]*100, 0.1)
			echo_players[i].play()
			echo_wait_times[i] = -1.0
