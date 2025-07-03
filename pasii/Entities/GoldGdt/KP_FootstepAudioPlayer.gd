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
@export var player_hull : CharacterBody3D
@export var rays : int = 128
@export_range(0.0, 1.0) var reflection_probability : float = 0.8
func _ready():
	original_loudness = AudioPlayer.volume_linear
	for i in rays:
		var ep = AudioPlayer.duplicate()
		ep.bus = "RTReverb"
		add_child(ep)
		echo_players.append(ep)
		echo_wait_times.append(-1.0)

func _random_dir() -> Vector3:
	randomize()
	var rx = randf_range(-1, 1)
	var ry = randf_range(0.1, 1) #hemispherical trace
	var rz = randf_range(-1, 1)
	var dir = Vector3(rx, ry, rz)
	return Vector3(rx, ry, rz)
func play_auralized():
	var space_state = get_world_3d().direct_space_state
	
	AudioPlayer.play()
	for i in echo_players.size():
		var dir = _random_dir()
		#echo_wait_times[i] = 0
		#if echo_players[i].playing:
		#	return
		
		var echonet = AudioServer.get_bus_effect(3, 1)
		var query = PhysicsRayQueryParameters3D.create(global_position, dir * 1000)
		query.exclude = [self, player_hull]
		var result = space_state.intersect_ray(query)
		var refldist = 0.0
		echo_players[i].volume_linear = AudioPlayer.volume_linear
		if result:
			echo_players[i].global_position = result.position
			var d = global_position.distance_to(result.position)
			echo_wait_times[i] = (1000/343)*(d*2)
			echonet.tap1_delay_ms = echo_wait_times[i]
			echo_players[i].bus = "RTReverb"
			
			if randf_range(0.5, 1.0) > reflection_probability:
				query = PhysicsRayQueryParameters3D.create(result.position, dir.reflect(result.normal) + dir * 50)
				if space_state.intersect_ray(query):
					result = space_state.intersect_ray(query)
					echo_players[i].global_position = lerp(echo_players[i].global_position, result.position, 0.5)
					d += global_position.distance_to(result.position)
					echo_wait_times[i] += (1000/343)*(d*2)
					echo_players[i].volume_linear *= 0.1
					echo_players[i].unit_size *= 2
					echonet.feedback_delay_ms = echo_wait_times[i]
					echonet.tap2_delay_ms = echo_wait_times[i]
					echo_players[i].bus = "RTReverbRefl"
					if space_state.intersect_ray(query):
						result = space_state.intersect_ray(query)
						echo_players[i].global_position = lerp(echo_players[i].global_position, result.position, 0.5)
						d += global_position.distance_to(result.position)
						echo_wait_times[i] += (1000/343)*(d*2)
						echo_players[i].volume_linear *= 0.1
						echo_players[i].unit_size *= 2
						echonet.feedback_delay_ms = (echonet.feedback_delay_ms + echo_wait_times[i])/2
						echonet.tap2_delay_ms = echo_wait_times[i] / 8
						echo_players[i].bus = "RTReverbRefl"
func getMaterial() -> Color:
	var image = MaterialViewportTexture.get_image()
	var pixel_0_0 = image.get_pixel(0, 0)
	print("Material Colour:" + str(pixel_0_0))
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
					AudioPlayer.stream = current_sound_tex.footsteps
					AudioPlayer.volume_linear = original_loudness * child.sound_texture.footstep_loudness_linear
					#AudioPlayer.play()
					play_auralized()
			else:
				current_sound_tex = DefaultSoundTexture
				AudioPlayer.stream = current_sound_tex.footsteps
				AudioPlayer.volume_linear = DefaultSoundTexture.footstep_loudness_linear * original_loudness
				#AudioPlayer.play()
				play_auralized()
		for i in echo_players.size():
			echo_players[i].stream = current_sound_tex.footsteps
			echo_players[i].volume_linear *= current_sound_tex.footstep_running_loudness_linear / (rays/1)
		#var gr = col.get_groups()
		#print(getMaterial())
		#if AudioManager.SoundPassMappings.find_key(getMaterial()):
		#	AudioPlayer.stream = AudioManager.SoundPassMappings.find_key(getMaterial())
		#	print(AudioManager.SoundPassMappings.find_key(getMaterial()))
			#AudioPlayer.play()

func _process(delta: float) -> void:
	MaterialCamera.global_position = global_position
	#MaterialCamera.global_rotation = global_rotation
	#MaterialCamera.global_basis = global_basis

func _physics_process(delta: float) -> void:
	for i in echo_wait_times.size():
		if !echo_wait_times[i] == -1.0:
			echo_wait_times[i] -=  delta*1000
			if echo_wait_times[i] <= 0.0:
				echo_players[i].pitch_scale = 2.0
				echo_players[i].play()
				echo_wait_times[i] = -1.0

		var reverb = AudioServer.get_bus_effect(3, 5)
		reverb.room_size = randf_range(0.7, 0.95)
		
