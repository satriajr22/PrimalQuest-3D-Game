extends CharacterBody3D

signal health_changed(new_health)
signal xp_changed(amount)
signal level_up(level)
signal died

@export var max_health: float = 100.0
@export var move_speed: float = 6.5
@export var sprint_speed: float = 10.5
@export var jump_force: float = 7.0
@export var gravity: float = 20.0
@export var attack_damage: float = 12.0
@export var heavy_damage: float = 24.0
@export var stamina_max: float = 100.0
@export var attack_range: float = 2.2

var health: float = max_health
var stamina: float = stamina_max
var xp: float = 0.0
var level: int = 1
var double_jump_ready: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0
var heavy_attack_ready: bool = false
var inventory: Array = ["Rusty Blade", "Survival Kit"]
var current_target: Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var sword_trail: MeshInstance3D = $SwordTrail

func _ready() -> void:
    health_changed.emit(health)
    xp_changed.emit(xp)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    set_physics_process(true)

func _physics_process(delta: float) -> void:
    if health <= 0.0:
        return

    _handle_camera(delta)
    _handle_movement(delta)
    _handle_attacks(delta)
    _handle_interaction()
    move_and_slide()

func _handle_camera(_delta: float) -> void:
    var camera_target = global_position + Vector3(0, 1.5, 0)
    camera_pivot.global_position = camera_target
    var desired_rotation = camera_pivot.rotation.y
    camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, desired_rotation, 0.12)

func _handle_movement(delta: float) -> void:
    var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction = Vector3(input_vec.x, 0, input_vec.y)
    direction = direction.rotated(Vector3.UP, rotation.y)

    var running = Input.is_action_pressed("sprint") && stamina > 0.0
    var target_speed = running ? sprint_speed : move_speed

    if direction.length() > 0.05:
        var look_target = global_position + direction
        look_at(look_target, Vector3.UP)
        rotation.x = 0.0
        rotation.z = 0.0
        velocity.x = direction.x * target_speed
        velocity.z = direction.z * target_speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, target_speed)
        velocity.z = move_toward(velocity.z, 0.0, target_speed)

    if Input.is_action_just_pressed("jump"):
        if is_on_floor():
            velocity.y = jump_force
            double_jump_ready = true
        elif double_jump_ready:
            velocity.y = jump_force * 1.1
            double_jump_ready = false

    if running:
        stamina = max(0.0, stamina - 18.0 * delta)
    else:
        stamina = min(stamina_max, stamina + 12.0 * delta)

    if Input.is_action_just_pressed("dodge"):
        var dodge_dir = direction
        if dodge_dir.length() < 0.1:
            dodge_dir = -transform.basis.z
        velocity.x = dodge_dir.x * 14.0
        velocity.z = dodge_dir.z * 14.0

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = min(velocity.y, 0.0)

func _handle_attacks(delta: float) -> void:
    if is_attacking:
        attack_timer -= delta
        sword_trail.visible = true
        if attack_timer <= 0.0:
            is_attacking = false
            sword_trail.visible = false

    if Input.is_action_just_pressed("attack") && not is_attacking:
        _trigger_attack(attack_damage, 0.38)
    elif Input.is_action_just_pressed("heavy_attack") && not is_attacking:
        _trigger_attack(heavy_damage, 0.65)

func _trigger_attack(damage: float, duration: float) -> void:
    is_attacking = true
    attack_timer = duration
    sword_trail.visible = true
    var hitbox_radius = attack_range
    var space = get_world_3d().direct_space_state
    var query = PhysicsShapeQueryParameters3D.new()
    var shape = SphereShape3D.new()
    shape.radius = hitbox_radius
    query.shape = shape
    query.transform = Transform3D(Basis(), global_position + transform.basis.z * 1.4)
    query.collision_mask = 1
    var result = space.intersect_shape(query, 32)
    for hit in result:
        var body = hit.get("collider")
        if body and body.has_method("apply_damage") and body != self:
            body.apply_damage(damage)
    pass

func _handle_interaction() -> void:
    if Input.is_action_just_pressed("interact"):
        var targets = get_tree().get_nodes_in_group("collectibles")
        for item in targets:
            if item.global_position.distance_to(global_position) < 3.0:
                inventory.append(item.name)
                item.queue_free()
                xp += 10
                xp_changed.emit(xp)
                break

func apply_damage(amount: float) -> void:
    health = max(0.0, health - amount)
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

func save_data() -> Dictionary:
    return {
        "health": health,
        "max_health": max_health,
        "level": level,
        "xp": xp,
        "inventory": inventory,
        "stamina": stamina,
        "position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}
    }

func load_data(data: Dictionary) -> void:
    health = data.get("health", health)
    level = data.get("level", level)
    xp = data.get("xp", xp)
    inventory = data.get("inventory", inventory)
    stamina = data.get("stamina", stamina_max)
    var pos = data.get("position", {})
    if pos.size() > 0:
        global_position = Vector3(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)), float(pos.get("z", 0.0)))
