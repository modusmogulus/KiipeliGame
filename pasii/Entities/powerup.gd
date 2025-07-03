class_name KP_Powerup extends MeshInstance3D
@export var player_params : PlayerParameters
@export var powerup_icon : Texture2D
@export var powerup_sprite_3d : Texture2D
@export var powerup_type_enum : enumsKP.powerups

var active : bool = true

func _ready() -> void:
	
	var mat0 = StandardMaterial3D.new()
	mat0.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat0.albedo_texture = powerup_sprite_3d
	mat0.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_OBJECT_DITHER
	mat0.distance_fade_min_distance = 24.0 #min must be bigger than max.
	mat0.distance_fade_max_distance = 12.0
	mat0.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat0.render_priority = 22
	mat0.no_depth_test = true
	
	set_surface_override_material(0, mat0)
func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if !active: return
	
	if body.is_in_group("Player"):
		body.add_powerup(self)
		self.visible = false
		active = false
