extends Node3D

var player_ref: CharacterBody3D
var enemy_count: int = 0
var boss_ref: CharacterBody3D

func initialize(player: CharacterBody3D) -> void:
    player_ref = player
    _build_world()
    _spawn_enemies()
    _spawn_collectibles()

func _build_world() -> void:
    var ground = MeshInstance3D.new()
    var ground_mesh = BoxMesh.new()
    ground_mesh.size = Vector3(220, 1, 220)
    ground.mesh = ground_mesh
    ground.position = Vector3(0, -0.5, 0)
    add_child(ground)
    ground.name = "Ground"

    _add_area("City", Vector3(-25, 0, 0), Vector3(30, 2, 30), Color(0.18, 0.2, 0.25, 0.22))
    _add_area("Forest", Vector3(25, 0, -18), Vector3(28, 2, 28), Color(0.12, 0.42, 0.18, 0.22))
    _add_area("Village", Vector3(30, 0, 22), Vector3(24, 2, 24), Color(0.42, 0.38, 0.28, 0.22))
    _add_area("Cavern", Vector3(-30, 0, 28), Vector3(18, 2, 18), Color(0.15, 0.15, 0.2, 0.22))
    _add_area("BossArena", Vector3(0, 0, -30), Vector3(18, 2, 18), Color(0.65, 0.12, 0.12, 0.24))

    for i in range(10):
        var building = MeshInstance3D.new()
        var box = BoxMesh.new()
        box.size = Vector3(2.6, 8.0, 2.6)
        building.mesh = box
        building.position = Vector3(-24 + (i % 4) * 7, 4.0, -10 + (i / 4) * 6)
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.5, 0.58, 0.72, 1.0)
        building.material_override = mat
        add_child(building)
        building.name = "DecorBuilding_%s" % i

    for i in range(6):
        _add_tree(Vector3(10 + i * 7, 1, -14), 2.0 + (i % 3) * 0.5)
        _add_tree(Vector3(-16 + i * 5, 1, 18), 1.8 + (i % 2) * 0.8)

func _add_area(area_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var area = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    area.mesh = mesh
    area.position = pos
    area.material_override = StandardMaterial3D.new()
    area.material_override.albedo_color = color
    area.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    add_child(area)
    area.name = "Area_%s" % area_name
    return area

func _add_tree(pos: Vector3, scale_value: float) -> void:
    var trunk = MeshInstance3D.new()
    var trunk_mesh = CylinderMesh.new()
    trunk_mesh.height = 3.2
    trunk_mesh.top_radius = 0.22
    trunk_mesh.bottom_radius = 0.28
    trunk.mesh = trunk_mesh
    trunk.position = pos
    trunk.scale = Vector3(0.45 * scale_value, 1.0, 0.45 * scale_value)
    add_child(trunk)

    var leaves = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 1.2 * scale_value
    sphere.height = 2.4 * scale_value
    leaves.mesh = sphere
    leaves.position = pos + Vector3(0, 2.2, 0)
    add_child(leaves)

func _spawn_collectibles() -> void:
    for i in range(10):
        var orb = MeshInstance3D.new()
        var mesh = SphereMesh.new()
        mesh.radius = 0.4
        mesh.height = 0.8
        orb.mesh = mesh
        orb.position = Vector3(-24 + i * 5, 1.2, 18 + (i % 2) * 8)
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.4, 0.9, 1.0, 1.0)
        mat.emission_enabled = true
        mat.emission = Color(0.2, 0.8, 1.0, 1.0)
        mat.emission_energy_multiplier = 0.8
        orb.material_override = mat
        orb.add_to_group("collectibles")
        add_child(orb)

func _spawn_enemies() -> void:
    _spawn_enemy("melee", Vector3(14, 1, 4))
    _spawn_enemy("ranged", Vector3(-18, 1, -5))
    _spawn_enemy("fast", Vector3(28, 1, -16))
    _spawn_enemy("tank", Vector3(-12, 1, 26))
    _spawn_enemy("flying", Vector3(16, 4, -27))
    _spawn_enemy("elite", Vector3(-30, 1, 16))
    _spawn_enemy("melee", Vector3(6, 1, 24))
    _spawn_enemy("ranged", Vector3(34, 1, 12))
    boss_ref = _spawn_boss(Vector3(0, 1, -31))

func _spawn_enemy(type_name: String, pos: Vector3) -> void:
    var enemy_scene = load("res://scenes/Enemy.tscn")
    var enemy = enemy_scene.instantiate()
    enemy.position = pos
    enemy.type = type_name
    enemy.player_reference = player_ref
    enemy.name = "%sEnemy_%d" % [type_name, enemy_count]
    enemy_count += 1
    add_child(enemy)

func _spawn_boss(pos: Vector3) -> CharacterBody3D:
    var boss_scene = load("res://scenes/Boss.tscn")
    var boss = boss_scene.instantiate()
    boss.position = pos
    boss.player_reference = player_ref
    boss.name = "BossWarden"
    add_child(boss)
    return boss
