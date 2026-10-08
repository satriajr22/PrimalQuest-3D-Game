extends CharacterBody3D

var player_reference: CharacterBody3D
var type: String = "melee"
var health: float = 60.0
var max_health: float = 60.0
var speed: float = 2.8
var attack_damage: float = 10.0
var attack_range: float = 2.0
var detection_range: float = 12.0
var state: String = "patrol"
var attack_cooldown: float = 0.0
var alive: bool = true
var loot_value: int = 12
var patrol_time: float = 0.0

func _ready() -> void:
    _apply_type_stats()
    add_to_group("enemies")

func _apply_type_stats() -> void:
    match type:
        "melee":
            max_health = 60.0; speed = 2.8; attack_damage = 10.0; loot_value = 12
        "ranged":
            max_health = 45.0; speed = 2.2; attack_damage = 8.0; loot_value = 13
        "fast":
            max_health = 35.0; speed = 4.0; attack_damage = 7.0; loot_value = 15
        "tank":
            max_health = 100.0; speed = 1.7; attack_damage = 18.0; loot_value = 20
        "flying":
            max_health = 40.0; speed = 3.4; attack_damage = 9.0; loot_value = 18
        "elite":
            max_health = 85.0; speed = 2.6; attack_damage = 16.0; loot_value = 28
    health = max_health

func _physics_process(delta: float) -> void:
    if not alive:
        return

    var player = player_reference if player_reference else get_tree().get_first_node_in_group("player")
    if player == null:
        return

    var distance = global_position.distance_to(player.global_position)
    state = "patrol" if distance > detection_range else "chase"

    if state == "patrol":
        patrol_time += delta
        velocity.x = sin(patrol_time * 0.5) * 0.8
        velocity.z = cos(patrol_time * 0.7) * 0.8
    elif state == "chase":
        var dir = player.global_position - global_position
        dir.y = 0
        if dir.length() > 0.1:
            dir = dir.normalized()
            var target_speed = speed
            if distance < attack_range:
                state = "attack"
                target_speed = 0.0
            velocity.x = dir.x * target_speed
            velocity.z = dir.z * target_speed
            look_at(player.global_position, Vector3.UP)

    if state == "attack":
        attack_cooldown -= delta
        velocity.x = move_toward(velocity.x, 0.0, 12.0)
        velocity.z = move_toward(velocity.z, 0.0, 12.0)
        if attack_cooldown <= 0.0:
            if player and player.has_method("apply_damage"):
                player.apply_damage(attack_damage)
            attack_cooldown = 1.2

    if not is_on_floor():
        velocity.y -= 22.0 * delta
    else:
        velocity.y = min(velocity.y, 0.0)

    move_and_slide()

func apply_damage(amount: float) -> void:
    if not alive:
        return
    health -= amount
    if health <= 0.0:
        alive = false
        var player = player_reference if player_reference else get_tree().get_first_node_in_group("player")
        if player and player.has_method("add_xp"):
            player.add_xp(float(loot_value))
        queue_free()
