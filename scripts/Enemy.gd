extends CharacterBody3D

signal died
signal health_changed(new_health)
signal xp_changed(value)
signal level_up(level)

var player_reference: CharacterBody3D
var type: String = "melee"
var health: float = 60.0
var max_health: float = 60.0
var speed: float = 3.0
var attack_damage: float = 10.0
var attack_range: float = 2.0
var detection_range: float = 12.0
var state: String = "patrol"
var alive: bool = true
var attack_cooldown: float = 0.0
var loot_value: int = 10

func _ready() -> void:
    _apply_type_stats()
    add_to_group("enemies")

func _apply_type_stats() -> void:
    match type:
        "melee":
            max_health = 60.0; speed = 2.8; attack_damage = 10.0; loot_value = 10
        "ranged":
            max_health = 45.0; speed = 2.4; attack_damage = 8.0; loot_value = 12
        "fast":
            max_health = 35.0; speed = 4.4; attack_damage = 7.0; loot_value = 12
        "tank":
            max_health = 100.0; speed = 1.6; attack_damage = 18.0; loot_value = 18
        "flying":
            max_health = 40.0; speed = 3.6; attack_damage = 9.0; loot_value = 14
        "elite":
            max_health = 80.0; speed = 2.8; attack_damage = 16.0; loot_value = 25
    health = max_health

func _physics_process(delta: float) -> void:
    if not alive:
        return

    var player = get_tree().get_first_node_in_group("player")
    if player == null:
        return

    var distance = global_position.distance_to(player.global_position)
    if distance < detection_range:
        state = "chase"
    else:
        state = "patrol"

    if state == "patrol":
        position.x += sin(Time.get_ticks_msec() * 0.001) * delta * 0.8
    elif state == "chase":
        var dir = (player.global_position - global_position)
        dir.y = 0
        if dir.length() > 0.1:
            dir = dir.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            look_at(player.global_position, Vector3.UP)
            if distance < attack_range:
                state = "attack"
    else:
        velocity.x = move_toward(velocity.x, 0.0, 10.0)
        velocity.z = move_toward(velocity.z, 0.0, 10.0)

    if state == "attack":
        attack_cooldown -= delta
        if attack_cooldown <= 0.0:
            if player and player.has_method("apply_damage"):
                player.apply_damage(attack_damage)
            attack_cooldown = 1.2

    if not is_on_floor():
        velocity.y -= 20.0 * delta
    else:
        velocity.y = min(velocity.y, 0.0)

    move_and_slide()

func apply_damage(amount: float) -> void:
    if not alive:
        return
    health -= amount
    if health <= 0.0:
        alive = false
        state = "dead"
        var player = get_tree().get_first_node_in_group("player")
        if player:
            player.add_xp(loot_value)
        queue_free()
