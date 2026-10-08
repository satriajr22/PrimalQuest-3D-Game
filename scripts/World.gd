extends Node3D

var player_ref: CharacterBody3D
var enemy_count = 0
var boss_ref: CharacterBody3D

func initialize(player: CharacterBody3D) -> void:
    player_ref = player
    _build_world()
    _spawn_enemies()
    _spawn_collectibles()

func _build_world() -> void:
    for child in get_children():
        if child.name.begins_with("Decor") or child.name.begins_with("Area"):
            child.queue_free()

    var base = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = Vector3(200, 1, 200)
    base.mesh = mesh
    base.position = Vector3(0, -0.5, 0)
    add_child(base)
    base.name = "Ground"

    var city_zone = _add_zone("City", Vector3(-25, 0, 0), Vector3(28, 2, 28), Color(0.2, 0.2, 0.25, 1))
    var forest_zone = _add_zone("Forest", Vector3(28, 0, -18), Vector3(26, 2, 26), Color(0.1, 0.5, 0.18, 1))
    var ruins_zone = _add_zone("Ruins", Vector3(28, 0, 22), Vector3(22, 2, 22), Color(0.5, 0.45, 0.3, 1))
    var cave_zone = _add_zone("Cave", Vector3(-30, 0, 28), Vector3(18, 2, 18), Color(0.15, 0.15, 0.2, 1))
    var boss_zone = _add_zone("Boss Arena", Vector3(0, 0, -30), Vector3(18, 2, 18), Color(0.7, 0.1, 0.15, 1))

    _add_tree(Vector3(12, 1, -14), 2.5)
    _add_tree(Vector3(18, 1, -10), 3.0)
    _add_tree(Vector3(-20, 1, 14), 2.0)
    _add_tree(Vector3(35, 1, 20), 2.6)
    _add_tree(Vector3(-35, 1, -16), 3.2)

    for i in range(12):
        var building = MeshInstance3D.new()
        var box = BoxMesh.new()
        box.size = Vector3(2.5, 8.0, 2.5)
        building.mesh = box
        building.position = Vector3(-20 + (i % 4) * 6, 4.0, -10 + (i / 4) * 5)
        building.material_override = StandardMaterial3D.new()
        building.material_override.albedo_color = Color(0.5, 0.55, 0.7, 1)
        add_child(building)
        building.name = "DecorBuilding%s" % i

func _add_zone(zone_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var zone = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    zone.mesh = mesh
    zone.position = pos
    zone.material_override = StandardMaterial3D.new()
    zone.material_override.albedo_color = color
    zone.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    zone.material_override.albedo_color.a = 0.18
    add_child(zone)
    zone.name = "Area_%s" % zone_name
    return zone

func _add_tree(pos: Vector3, scale_value: float) -> void:
    var trunk = MeshInstance3D.new()
    var trunk_mesh = CylinderMesh.new()
    trunk_mesh.height = 3.4
    trunk_mesh.top_radius = 0.2
    trunk_mesh.bottom_radius = 0.25
    trunk.mesh = trunk_mesh
    trunk.position = pos
    trunk.scale = Vector3(scale_value * 0.3, 1.0, scale_value * 0.3)
    add_child(trunk)
    trunk.name = "TreeTrunk"

    var leaf = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 1.3 * scale_value
    sphere.height = 2.6 * scale_value
    leaf.mesh = sphere
    leaf.position = pos + Vector3(0, 2.2, 0)
    leaf.scale = Vector3(1.0, 1.0, 1.0)
    add_child(leaf)
    leaf.name = "TreeLeaf"

func _spawn_enemies() -> void:
    _spawn_enemy("melee", Vector3(18, 1, 0))
    _spawn_enemy("ranged", Vector3(-20, 1, -6))
    _spawn_enemy("fast", Vector3(30, 1, -18))
    _spawn_enemy("tank", Vector3(-10, 1, 28))
    _spawn_enemy("flying", Vector3(16, 4, -28))
    _spawn_enemy("elite", Vector3(-32, 1, 14))
    _spawn_enemy("melee", Vector3(4, 1, 20))
    _spawn_enemy("ranged", Vector3(34, 1, 10))
    boss_ref = _spawn_boss(Vector3(0, 1, -32))

func _spawn_collectibles() -> void:
    for i in range(8):
        var orb = MeshInstance3D.new()
        var sphere = SphereMesh.new()
        sphere.radius = 0.35
        sphere.height = 0.7
        orb.mesh = sphere
        orb.position = Vector3(-24 + i * 8, 1.5, 16 + (i % 2) * 6)
        orb.material_override = StandardMaterial3D.new()
        orb.material_override.albedo_color = Color(0.4, 0.9, 1.0, 1)
        orb.name = "Collectible_%s" % i
        add_child(orb)

func _spawn_enemy(type: String, pos: Vector3) -> void:
    var enemy_scene = load("res://scenes/Enemy.tscn")
    var enemy = enemy_scene.instantiate()
    enemy.position = pos
    enemy.type = type
    enemy.player_reference = player_ref
    add_child(enemy)
    enemy_count += 1
    enemy.name = "%sEnemy_%d" % [type, enemy_count]

func _spawn_boss(pos: Vector3) -> CharacterBody3D:
    var boss_scene = load("res://scenes/Boss.tscn")
    var boss = boss_scene.instantiate()
    boss.position = pos
    boss.player_reference = player_ref
    add_child(boss)
    boss.name = "Boss"
    return boss
