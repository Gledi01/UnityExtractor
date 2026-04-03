extends Node3D

@export var chunk_size : float = 16.0
@export var render_distance : int = 4
@export var player : NodePath

@export var pohon_scenes : Array[PackedScene]
@export var jumlah_pohon_per_chunk : int = 5

@export var rumput_mesh : Mesh
@export var rumput_material : Material
@export var jumlah_rumput_per_chunk : int = 100

@onready var player_node = get_node(player)

var chunks = {}
var chunk_mesh : PlaneMesh

func _ready():
    chunk_mesh = PlaneMesh.new()
    chunk_mesh.size = Vector2(chunk_size, chunk_size)

func _process(_delta):
    update_chunks()

func update_chunks():
    var player_chunk = world_to_chunk(player_node.global_position)
    
    for x in range(-render_distance, render_distance + 1):
        for z in range(-render_distance, render_distance + 1):
            var chunk_pos = Vector2i(player_chunk.x + x, player_chunk.y + z)
            if not chunks.has(chunk_pos):
                spawn_chunk(chunk_pos)
    
    for chunk_pos in chunks.keys():
        if abs(chunk_pos.x - player_chunk.x) > render_distance or \
           abs(chunk_pos.y - player_chunk.y) > render_distance:
            chunks[chunk_pos].queue_free()
            chunks.erase(chunk_pos)

func spawn_chunk(chunk_pos: Vector2i):
    var root = Node3D.new()
    add_child(root)
    root.position = Vector3(
        chunk_pos.x * chunk_size,
        0,
        chunk_pos.y * chunk_size
    )
    
    # Terrain
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = chunk_mesh
    root.add_child(mesh_instance)
    
    # Pohon
    if pohon_scenes.size() > 0:
        for i in jumlah_pohon_per_chunk:
            var scene = pohon_scenes[randi() % pohon_scenes.size()]
            var pohon = scene.instantiate()
            root.add_child(pohon)
            pohon.position = Vector3(
                randf_range(-chunk_size / 2, chunk_size / 2),
                0,
                randf_range(-chunk_size / 2, chunk_size / 2)
            )
            pohon.rotation_degrees.y = randf_range(0, 360)
    
    # Rumput
    if rumput_mesh != null:
        var mm = MultiMesh.new()
        mm.mesh = rumput_mesh
        mm.transform_format = MultiMesh.TRANSFORM_3D
        mm.instance_count = jumlah_rumput_per_chunk
        
        if rumput_material != null:
            var mesh_copy = mm.mesh.duplicate()
            mesh_copy.surface_set_material(0, rumput_material)
            mm.mesh = mesh_copy
        
        for i in jumlah_rumput_per_chunk:
            var t = Transform3D()
            t = t.rotated(Vector3.UP, randf_range(0, TAU))
            t.origin = Vector3(
                randf_range(-chunk_size / 2, chunk_size / 2),
                0,
                randf_range(-chunk_size / 2, chunk_size / 2)
            )
            mm.set_instance_transform(i, t)
        
        var mmi = MultiMeshInstance3D.new()
        mmi.multimesh = mm
        root.add_child(mmi)
    
    chunks[chunk_pos] = root

func world_to_chunk(pos: Vector3) -> Vector2i:
    return Vector2i(
        floor(pos.x / chunk_size),
        floor(pos.z / chunk_size)
    )
