@tool
extends Node

@export var visual_texture: Texture2D
@export var sound_texture: SoundTexture
@export var press_to_auto_sm: bool:
	set(value):
		auto_sm()
@export var root_node: Node3D

func auto_sm():
	for body in root_node.get_children():
		if body == StaticBody3D:
			for node in body.get_children():
				if node == MeshInstance3D:
					for i in 10:
						if node.mesh.get_active_material(i):
							var mat = node.mesh.get_active_material(i)
							var tex = mat.get_shader_param("albedo_texture")
							if tex == visual_texture:
								var sm = SoundMaterial.new()
								sm.sound_texture = sound_texture
								body.add_child(sm)
								body.name = body.name + " (auto)" + sound_texture.resource_name
	for node in root_node.get_children():
			if node == MeshInstance3D:
				var body = node.get_parent()
				if body.get_parent() == MeshInstance3D:
					for i in 10:
						if node.mesh.get_active_material(i):
							var mat = node.mesh.get_active_material(i)
							var tex = mat.get_shader_param("albedo_texture")
							if tex == visual_texture:
								var sm = SoundMaterial.new()
								sm.sound_texture = sound_texture
								node.add_child(sm)
								body.name = body.name + " (auto)" + sound_texture.resource_name
