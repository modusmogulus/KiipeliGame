class_name GoldGdt_Move extends Node

@export_group("Components")
@export var Parameters : PlayerParameters
@export var Body : GoldGdt_Body

@export var anim_tree : AnimationTree
@export var AnimHandler : KiipeliAnimHandler
@onready var state_machine = anim_tree["parameters/playback"]
# Adds to the player's velocity based on direction, speed and acceleration.
var jump_on : bool #set from controls.gd
var wallrun_wall_normal : Vector3 = Vector3.ZERO

func request_vault(wishdir) -> enumsKP.vault_states:
	if !Body: return enumsKP.vault_states.NONE
	if !Body.current_vault_state == enumsKP.vault_states.NONE:
		return enumsKP.vault_states.NONE
	var query = PhysicsRayQueryParameters3D.create(Body.global_position, Body.global_position+Body.get_camera_look_dir()*1.5)
	var query2 = PhysicsRayQueryParameters3D.create(Body.global_position + Vector3(0, 1.8, 0), Body.global_position+1.5*Body.get_camera_look_dir() * Vector3(1.0, 0.0, 1.0) + Vector3(0, 1.8, 0))
	query.exclude = [Body.collision_hull]
	query2.exclude = [Body.collision_hull]
	var space_state = Body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	var result2 = space_state.intersect_ray(query2)
	if result.size() > 1 && result2.size() < 1:
		if Body.vault_cooldown_timer > 0:
			return enumsKP.vault_states.NONE
		Body.vault_cooldown_timer = Body.vault_cooldown_duration
		_vault(get_process_delta_time())
		Body.sfx_vault.play()
		AnimHandler.snap_hands_to(result.position, 0.8, 0.8)
		return enumsKP.vault_states.INITIAL_VAULT
	else:
		return enumsKP.vault_states.NONE

func request_wallrun() -> enumsKP.wallrun_states:
	if !Body: return enumsKP.wallrun_states.NONE
	var query = PhysicsRayQueryParameters3D.create(Body.global_position, Body.global_position + Body.View.camera.global_basis.x * -1.1)
	var query2 = PhysicsRayQueryParameters3D.create(Body.global_position, Body.global_position + Body.View.camera.global_basis.x * 1.1)
	query.exclude = [Body.collision_hull]
	query2.exclude = [Body.collision_hull]
	
	var space_state = Body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	var result2 = space_state.intersect_ray(query2)
	#FIXME: im touch-starved
	if result.size() > 0 or result2.size() > 0: #is there runnable walls?
		#there is
		if result.size() > 0: #is there runnable left wall?
			wallrun_wall_normal = result.normal
			return enumsKP.wallrun_states.LEFT #exit function and tell em its left
		if result2.size() > 0: #is there runnable right wall?
			wallrun_wall_normal = result2.normal
			
			return enumsKP.wallrun_states.RIGHT #exit function and tell em its right
	print("NO WALLRUn") #player is stupud. there is no wall
	
	return enumsKP.wallrun_states.NONE #if we didnt exit func due to wall found, no wall available
		

func _accelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
	if !Body: return
	
	var addspeed : float
	var accelspeed : float
	var currentspeed : float
	
	# See if we are changing direction a bit
	currentspeed = Body.velocity.dot(wishdir)
	
	# Reduce wishspeed by the amount of veer.
	addspeed = wishspeed - currentspeed
	
	# If not going to add any speed, done.
	if addspeed <= 0:
		return;
		
	# Determine the amount of acceleration.
	accelspeed = accel * wishspeed * delta
	
	# Cap at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	# Adjust velocity.
	Body.velocity += accelspeed * wishdir

# Adds to the player's velocity based on direction, speed and acceleration. 
# The difference between _accelerate() and this function is it caps the maximum speed you can accelerate to.
func _airaccelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float, max_speed_multiplier = null) -> void:
	if !Body: return
	
	var addspeed : float
	var accelspeed : float
	var currentspeed : float
	var wishspd : float = wishspeed
	if max_speed_multiplier == null:
		max_speed_multiplier = 1.0
	if (wishspd > Parameters.MAX_AIR_SPEED * max_speed_multiplier):
		wishspd = Parameters.MAX_AIR_SPEED * max_speed_multiplier
	
	# See if we are changing direction a bit
	currentspeed = Body.velocity.dot(wishdir)
	
	# Reduce wishspeed by the amount of veer.
	addspeed = wishspd - currentspeed
	
	# If not going to add any speed, done.
	if addspeed <= 0:
		return;
		
	# Determine the amount of acceleration.
	accelspeed = accel * wishspeed * delta
	
	# Cap at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	# Adjust velocity.
	Body.velocity += accelspeed * wishdir
	if jump_on:
		if Body.current_wallrun_state != enumsKP.wallrun_states.NONE:
			#re-request wallrun because otherwise player will float when wall ends
			Body.current_wallrun_state = request_wallrun()
			if !request_wallrun():
				Body.current_wallrun_state = enumsKP.wallrun_states.NONE
				_jump(delta)
				#Move._accelerate(delta, Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, View.horizontal_view.rotation.y), -100.0, 200.0)
			#_accelerate(delta, move_dir.normalized(), 8.0, 20.0)
			
			#print(move_dir.normalized().dot(Body.velocity.normalized()))
			
	else:
		Body.current_wallrun_state = enumsKP.wallrun_states.NONE

# Applies friction to the player's horizontal velocity
func _friction(delta: float, strength: float) -> void:
	if !Body: return
	
	var speed = Body.velocity.length()
	
	# Bleed off some speed, but if we have less that the bleed
	# threshold, bleed the threshold amount.
	var control =  Parameters.STOP_SPEED if (speed < Parameters.STOP_SPEED) else speed
	
	# Add the amount to the drop amount
	var drop = control * (Parameters.FRICTION * strength) * delta
	
	# Scale the velocity.
	var newspeed = speed - drop
	
	if newspeed < 0:
		newspeed = 0
	
	if speed > 0:
		newspeed /= speed
	
	Body.velocity.x *= newspeed
	Body.velocity.z *= newspeed

# Applies a jump force to the player.
func _jump(delta: float) -> void:
	#print(request_wallrun())
	# Apply the jump impulse
	Body.velocity.y = sqrt(2 * Parameters.GRAVITY * Parameters.JUMP_HEIGHT)
	
	# Add in some gravity correction
	Body.velocity.y -= (Parameters.GRAVITY * delta * 0.5 )
	
	# If the Player Parameters wants us to clip the velocity, do it.
	match Parameters.BUNNYHOP_CAP_MODE:
		Parameters.BunnyhopCapMode.NONE:
			pass
		Parameters.BunnyhopCapMode.THRESHOLD:
			_bunnyhop_capmode_threshold()
		Parameters.BunnyhopCapMode.DROP:
			_bunnyhop_capmode_drop()

func request_walljump(delta):
	if request_wallrun() != enumsKP.wallrun_states.NONE:
		return
	#for walljump
	var query = PhysicsRayQueryParameters3D.create(Body.global_position - Body.View.horizontal_view.global_basis.z * -0.1, Body.global_position + Body.View.horizontal_view.global_basis.z * -Parameters.VAULT_CHECK_DISTANCE*0.5)
	var query2 = PhysicsRayQueryParameters3D.create(Vector3.UP + Body.global_position - Body.View.horizontal_view.global_basis.z * -0.2, Vector3.UP + Body.global_position + Body.View.horizontal_view.global_basis.z * -Parameters.VAULT_CHECK_DISTANCE*0.5)
	#for wallkicks
	var query3 = PhysicsRayQueryParameters3D.create(Body.global_position - Body.View.horizontal_view.global_basis.z * 0.1, Body.global_position + Body.View.horizontal_view.global_basis.z * Parameters.VAULT_CHECK_DISTANCE *0.5)
	#var query4 = PhysicsRayQueryParameters3D.create(Vector3.UP + Body.global_position - Body.View.horizontal_view.global_basis.z * 0.2, Vector3.UP + Body.global_position + Body.View.horizontal_view.global_basis.z * Parameters.VAULT_CHECK_DISTANCE)
	
	query.exclude = [Body.collision_hull]
	query2.exclude = [Body.collision_hull]
	query3.exclude = [Body.collision_hull]
	#query4.exclude = [Body.collision_hull]
	var space_state = Body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	var result2 = space_state.intersect_ray(query2) #result 2 to make it not interfecre with vault
	var result3 = space_state.intersect_ray(query3)
	#var result4 = space_state.intersect_ray(query4)
	#walljump
	if result.size() > 1 && result2.size() > 1:
		if Body.walljumps_left > 0:
			Body.velocity.y = sqrt(2 * Parameters.GRAVITY * Parameters.JUMP_HEIGHT)
			Body.walljumps_left -= 1
			Body.sfx_vault.play()
			AnimHandler.walljumpstate = "WALLJUMP"
			AnimHandler.snap_hands_to(result.position, 0.8, 0.3)
			AnimHandler.switch_hand()
			Body.current_walljump_state = enumsKP.walljump_states.WALLJUMP
	#wallkick
	if result3.size() > 1:
		if Body.wallkicks_left > 0:
			Body.velocity.y = 1.5*sqrt(2 * Parameters.GRAVITY * Parameters.JUMP_HEIGHT)
			
			Body.velocity +=  Body.View.horizontal_view.global_basis.z * -3.2
			Body.wallkicks_left -= 1
			Body.sfx_vault.play()
			AnimHandler.walljumpstate = "WALLKICK"
			AnimHandler.switch_hand()
			Body.current_walljump_state = enumsKP.walljump_states.WALLKICK
func _vault(delta: float) -> void:
	Body.velocity.y = sqrt(2 * Parameters.GRAVITY * (Parameters.JUMP_HEIGHT * 0.5))
	Body.velocity += Body.get_camera_look_dir() * 3.0
	Body.current_vault_state = enumsKP.vault_states.NONE
	AnimHandler.vaultstate = "VAULTING" #This is set to false when player velocity y vector is negative (in Body handler)
	Body._duck(true)
	Body.global_position.y += 1.6
	Body.velocity_before_vault = Body.velocity
# Crops horizontal velocity down to a defined maximum threshold.
func _bunnyhop_capmode_threshold() -> void:
	var spd : float
	var fraction : float
	var maxscaledspeed : float
	
	# Calculate what the maximum speed is.
	maxscaledspeed = Parameters.SPEED_THRESHOLD_FACTOR * Parameters.MAX_SPEED
	
	# Avoid divide-by-zero errors.
	if (maxscaledspeed <= 0): 
		return
	
	
	spd = Vector3(Body.velocity.x, 0.0, Body.velocity.z).length()
	
	if (spd <= maxscaledspeed): return
	
	fraction = (maxscaledspeed / spd)
	
	Body.velocity.x *= fraction
	Body.velocity.z *= fraction

# Crops horizontal velocity down to a defined dropped amount.
func _bunnyhop_capmode_drop() -> void:
	var spd : float
	var fraction : float
	var maxscaledspeed : float
	var dropspeed : float
	
	maxscaledspeed = Parameters.SPEED_THRESHOLD_FACTOR * Parameters.MAX_SPEED
	dropspeed = Parameters.SPEED_DROP_FACTOR * Parameters.MAX_SPEED
	
	if (maxscaledspeed <= 0): 
		return
	
	spd = Vector3(Body.velocity.x, 0.0, Body.velocity.z).length()
	
	if (spd <= maxscaledspeed): return
	
	fraction = (dropspeed / spd)
	
	Body.velocity.x *= fraction
	Body.velocity.z *= fraction
