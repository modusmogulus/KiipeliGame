@icon("src/gdticon.png")
class_name GoldGdt_Move extends Node

@export_group("Components")
@export var Parameters : PlayerParameters
@export var Body : GoldGdt_Body

@export var anim_tree : AnimationTree
@export var AnimHandler : KiipeliAnimHandler
@onready var state_machine = anim_tree["parameters/playback"]
# Adds to the player's velocity based on direction, speed and acceleration.

func request_vault(wishdir) -> enumsKP.vault_states:
	if !Body: return enumsKP.vault_states.NONE
	if !Body.current_vault_state == enumsKP.vault_states.NONE:
		return enumsKP.vault_states.NONE
	if !Body.current_wallrun_state == enumsKP.wallrun_states.NONE:
		return enumsKP.vault_states.NONE
	var query = PhysicsRayQueryParameters3D.create(Body.global_position - Body.View.horizontal_view.global_basis.z * -0.2, Body.global_position + Body.View.horizontal_view.global_basis.z * -Parameters.VAULT_CHECK_DISTANCE * wishdir.normalized().length())
	var query2 = PhysicsRayQueryParameters3D.create(Vector3.UP + Body.global_position - Body.View.horizontal_view.global_basis.z * -0.2, Vector3.UP + Body.global_position + Body.View.horizontal_view.global_basis.z * -Parameters.VAULT_CHECK_DISTANCE * wishdir.normalized().length())
	
	query.exclude = [Body.collision_hull]
	query2.exclude = [Body.collision_hull]
	var space_state = Body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	var result2 = space_state.intersect_ray(query2)
	if result.size() > 1 && result2.size() < 1:
		_vault(get_process_delta_time())
		print("vaulted")
		return enumsKP.vault_states.INITIAL_VAULT
	else:
		return enumsKP.vault_states.NONE

func request_wallrun() -> enumsKP.wallrun_states:
	if !Body: return enumsKP.wallrun_states.NONE
	var query = PhysicsRayQueryParameters3D.create(Body.global_position, Body.global_position + Body.View.camera.global_basis.x * -1)
	var query2 = PhysicsRayQueryParameters3D.create(Body.global_position, Body.global_position + Body.View.camera.global_basis.x * 1)
	query.exclude = [Body.collision_hull]
	query2.exclude = [Body.collision_hull]
	
	var space_state = Body.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result.size() > 0:
		print("LEFT WALLRUN")
		return enumsKP.wallrun_states.LEFT
	
	result = space_state.intersect_ray(query2)
	if result.size() > 0:
		
		print("RIGHT WALLRUN")
		return enumsKP.wallrun_states.RIGHT
	else:
		
		return enumsKP.wallrun_states.NONE
		

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
func _airaccelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
	if !Body: return
	
	var addspeed : float
	var accelspeed : float
	var currentspeed : float
	var wishspd : float = wishspeed
	
	if (wishspd > Parameters.MAX_AIR_SPEED):
		wishspd = Parameters.MAX_AIR_SPEED
	
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
	AnimHandler.is_grounded = false
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

func _vault(delta: float) -> void:
	Body.velocity.y += sqrt(4 * Parameters.GRAVITY * (Parameters.JUMP_HEIGHT * 1.5))
	Body.current_vault_state = enumsKP.vault_states.NONE
	AnimHandler.vaultstate = "VAULTING" #This is set to false when player velocity y vector is negative (in Body handler)
	Body._duck(true)
	Body.global_position.y += 0.6
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
