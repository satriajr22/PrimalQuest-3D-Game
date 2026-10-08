extends CharacterBody3D

signal health_changed(new_health)
signal xp_changed(value)
signal level_up(level)
signal died
signal inventory_changed(items)

@export var max_health: float = 100.0
@export var stamina_max: float = 100.0
@export var move_speed: float = 6.0
@export var sprint_speed: float = 10.0
@export var jump_force: float = 7.5
@export var gravity: float = 24.0
@export var attack_damage: float = 12.0
@export var heavy_damage: float = 24.0
@export var attack_range: float = 2.5

var health: float = max_health
var stamina: float = stamina_max
var xp: float = 0.0
var level: int = 1
var double_jump_ready: bool = false
var is_attacking: bool = false
var combo_index: int = 0
var attack_timer: float = 0.0
var dodge_timer: float = 0.0
var inventory: Array = ["Rusty Blade", "Field Kit"]
var special_charge: float = 0.0
var ultimate_charge: float = 0.0
var is_blocking: bool = false
var can_parry: bool = false
var current_area: String = "City"

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var sword_trail: MeshInstance3D = $SwordTrail

func _ready() -> void:
    add_to_group("player")
    _sync_state()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _sync_state() -> void:
    health_changed.emit(health)
    xp_changed.emit(xp)
    inventory_changed.emit(inventory)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - event.relative.y * 0.0014, -1.2, 1.2)
        rotation.y -= event.relative.x * 0.0022

func _physics_process(delta: float) -> void:
    if health <= 0.0:
        return

    _handle_movement(delta)
    _handle_attacks(delta)
    _handle_dodge(delta)
    _handle_specials(delta)
    _update_area_state()
    move_and_slide()

func _update_area_state() -> void:
    var pos = global_position
    if pos.x < -20 and pos.z > 20:
        current_area = "Cavern"
    elif pos.x > 20 and pos.z < -10:
        current_area = "Forest"
    elif pos.x > 20 and pos.z > 15:
        current_area = "Village"
    elif pos.z < -22:
        current_area = "Boss Arena"
    else:
        current_area = "City"

    if GameManager:
        GameManager.set_area(current_area)

func _handle_movement(delta: float) -> void:
    var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var move_dir = Vector3(input_vec.x, 0, input_vec.y)
    if move_dir.length() > 0.05:
        move_dir = move_dir.normalized()
        var desired_basis = Basis(Vector3.UP, rotation.y)
        var world_move = desired_basis * move_dir
        var sprinting = Input.is_action_pressed("sprint") && stamina > 0.0
        var target_speed = sprinting ? sprint_speed : move_speed

        velocity.x = world_move.x * target_speed
        velocity.z = world_move.z * target_speed

        if sprinting:
            stamina = max(0.0, stamina - 18.0 * delta)
            if camera:
                camera.fov = lerp(camera.fov, 86.0, 0.1)
        else:
            stamina = min(stamina_max, stamina + 12.0 * delta)
            if camera:
                camera.fov = lerp(camera.fov, 75.0, 0.1)

        var look_target = global_position + world_move.normalized()
        look_at(look_target, Vector3.UP)
        rotation.x = 0.0
        rotation.z = 0.0
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed)
        velocity.z = move_toward(velocity.z, 0.0, move_speed)
        stamina = min(stamina_max, stamina + 14.0 * delta)

    if Input.is_action_just_pressed("jump"):
        if is_on_floor():
            velocity.y = jump_force
            double_jump_ready = true
        elif double_jump_ready:
            velocity.y = jump_force * 1.1
            double_jump_ready = false

    if Input.is_action_pressed("block"):
        is_blocking = true
        stamina = max(0.0, stamina - 12.0 * delta)
    else:
        is_blocking = false

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = min(velocity.y, 0.0)
        double_jump_ready = false

func _handle_attacks(delta: float) -> void:
    if is_attacking:
        attack_timer -= delta
        sword_trail.visible = true
        if attack_timer <= 0.0:
            is_attacking = false
            sword_trail.visible = false

    if Input.is_action_just_pressed("attack") and not is_attacking:
        var dmg = attack_damage
        combo_index += 1
        if combo_index > 3:
            combo_index = 1
        if combo_index == 3:
            dmg *= 1.4
        _trigger_attack(dmg, 0.36)

    if Input.is_action_just_pressed("heavy_attack") and not is_attacking:
        _trigger_attack(heavy_damage, 0.58)

    if Input.is_action_just_pressed("parry"):
        can_parry = true
    elif Input.is_action_just_released("parry"):
        can_parry = false

func _trigger_attack(damage: float, duration: float) -> void:
    is_attacking = true
    attack_timer = duration
    sword_trail.visible = true
    special_charge = clamp(special_charge + 10.0, 0.0, 100.0)

    var target_pos = global_position + (-transform.basis.z * 1.7)
    var space = get_world_3d().direct_space_state
    var query = PhysicsShapeQueryParameters3D.new()
    var shape = SphereShape3D.new()
    shape.radius = attack_range
    query.shape = shape
    query.transform = Transform3D(Basis(), target_pos)
    query.collision_mask = 1
    var hits = space.intersect_shape(query, 8)

    for hit in hits:
        var body = hit.get("collider")
        if body and body != self and body.has_method("apply_damage"):
            body.apply_damage(damage)

func _handle_dodge(delta: float) -> void:
    if dodge_timer > 0.0:
        dodge_timer -= delta
    if Input.is_action_just_pressed("dodge"):
        var dir = Vector3.ZERO
        if velocity.length() > 0.1:
            dir = velocity.normalized()
        else:
            dir = -transform.basis.z
        velocity.x = dir.x * 12.5
        velocity.z = dir.z * 12.5
        dodge_timer = 0.25

func _handle_specials(delta: float) -> void:
    if Input.is_action_just_pressed("ultimate") and ultimate_charge >= 100.0:
        activate_ultimate()
        ultimate_charge = 0.0
    if Input.is_action_just_pressed("special") and special_charge >= 50.0:
        activate_special()
        special_charge = 0.0

    special_charge = clamp(special_charge + delta * 8.0, 0.0, 100.0)
    ultimate_charge = clamp(ultimate_charge + delta * 4.0, 0.0, 100.0)

func activate_special() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.global_position.distance_to(global_position) < 8.0 and enemy.has_method("apply_damage"):
            enemy.apply_damage(25.0)

func activate_ultimate() -> void:
    var boss = get_tree().get_first_node_in_group("boss")
    if boss and boss.has_method("apply_damage"):
        boss.apply_damage(60.0)
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.global_position.distance_to(global_position) < 10.0 and enemy.has_method("apply_damage"):
            enemy.apply_damage(40.0)

func apply_damage(amount: float) -> void:
    if health <= 0.0:
        return
    var protection = 0.0
    if is_blocking and stamina > 0.0:
        protection = 0.55
    health = max(0.0, health - (amount * (1.0 - protection)))
    health_changed.emit(health)
    if health <= 0.0:
        died.emit()
        print("Player defeated")

func add_xp(amount: float) -> void:
    xp += amount
    while xp >= 100.0:
        xp -= 100.0
        level += 1
        level_up.emit(level)
    xp_changed.emit(xp)

func add_item(item_name: String) -> void:
    inventory.append(item_name)
    inventory_changed.emit(inventory)

func save_data() -> Dictionary:
    return {
        "health": health,
        "max_health": max_health,
        "stamina": stamina,
        "xp": xp,
        "level": level,
        "inventory": inventory,
        "special_charge": special_charge,
        "ultimate_charge": ultimate_charge,
        "current_area": current_area,
        "position": {
            "x": global_position.x,
            "y": global_position.y,
            "z": global_position.z
        }
    }

func load_data(data: Dictionary) -> void:
    health = clamp(data.get("health", health), 0.0, max_health)
    stamina = clamp(data.get("stamina", stamina), 0.0, stamina_max)
    xp = data.get("xp", xp)
    level = int(data.get("level", level))
    inventory = data.get("inventory", inventory)
    special_charge = clamp(data.get("special_charge", special_charge), 0.0, 100.0)
    ultimate_charge = clamp(data.get("ultimate_charge", ultimate_charge), 0.0, 100.0)
    current_area = data.get("current_area", current_area)
    var pos = data.get("position", {})
    if pos:
        global_position = Vector3(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)), float(pos.get("z", 0.0)))
    _sync_state()

func get_inventory_snapshot() -> String:
    if inventory.size() == 0:
        return "Empty"
    return ", ".join(inventory)
