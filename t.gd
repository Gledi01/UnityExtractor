extends Node

@export var directional_light : NodePath
@export var world_env : NodePath
@export var jam_label : NodePath
@export var keterangan_label : NodePath

@export var sky_siang : PanoramaSkyMaterial
@export var sky_malam : PanoramaSkyMaterial

@export var durasi_hari : float = 600.0

@onready var light = get_node(directional_light)
@onready var env = get_node(world_env)
@onready var label = get_node(jam_label)
@onready var ket_label = get_node(keterangan_label)

var waktu : float = 0.0

func _process(delta):
    waktu += delta / durasi_hari
    if waktu >= 1.0:
        waktu = 0.0
    
    update_langit()
    update_cahaya()
    update_jam()

func update_langit():
    var t = 0.0
    if waktu < 0.25:
        t = 0.0
    elif waktu < 0.5:
        t = smoothstep(0.0, 1.0, (waktu - 0.25) / 0.25)
    elif waktu < 0.75:
        t = 1.0
    else:
        t = smoothstep(0.0, 1.0, 1.0 - (waktu - 0.75) / 0.25)
    
    env.environment.sky.sky_material = sky_siang if t > 0.5 else sky_malam
    env.environment.background_energy_multiplier = lerp(0.1, 1.0, t)

func update_cahaya():
    light.rotation_degrees.x = (waktu * 360.0) - 90.0
    
    var intensitas = clamp(sin(waktu * PI * 2.0 - PI / 2.0) + 1.0, 0.0, 1.0)
    light.light_energy = intensitas
    
    if intensitas > 0.6:
        light.light_color = Color(1.0, 0.95, 0.8)
    elif intensitas > 0.1:
        light.light_color = Color(1.0, 0.5, 0.2)
    else:
        light.light_color = Color(0.1, 0.1, 0.3)

func update_jam():
    var total_menit = int(waktu * 1440)
    var jam = total_menit / 60
    var menit = total_menit % 60
    label.text = "%02d:%02d" % [jam, menit]
    
    if jam >= 0 and jam < 3:
        ket_label.text = "Tengah Malam"
    elif jam >= 3 and jam < 5:
        ket_label.text = "Subuh"
    elif jam >= 5 and jam < 9:
        ket_label.text = "Pagi"
    elif jam >= 9 and jam < 11:
        ket_label.text = "Menjelang Siang"
    elif jam >= 11 and jam < 14:
        ket_label.text = "Siang"
    elif jam >= 14 and jam < 17:
        ket_label.text = "Sore"
    elif jam >= 17 and jam < 19:
        ket_label.text = "Petang"
    elif jam >= 19 and jam < 24:
        ket_label.text = "Malam"
