extends CharacterBody3D

signal boss_phase_changed(phase)

var player_reference: CharacterBody3D
var phase: int = 1
var max_health: float = 220.0
var health: float = 220.0
var speed: float = 2.6
var attack_damage: float = 18.0
var detection_range: float = 18.0
var attack_cooldown: float = 0.0
var alive: bool = true

func _ready() -> void:
    add_to_group("boss")

func _physics_process(delta: float) -> void:
    if not alive:
        return

    var player = player_reference if player_reference else get_tree().get_first_node_in_group("player")
    if player == null:
        return

    var distance = global_position.distance_to(player.global_position)
    if distance < detection_range:
        var dir = player.global_position - global_position
        dir.y = 0
        if dir.length() > 0.1:
            dir = dir.normalized()
            if distance > 3.2:
                velocity.x = dir.x * speed
                velocity.z = dir.z * speed
            else:
                velocity.x = move_toward(velocity.x, 0.0, 14.0)
                velocity.z = move_toward(velocity.z, 0.0, 14.0)
            look_at(player.global_position, Vector3.UP)

        attack_cooldown -= delta
        if distance < 3.2 and attack_cooldown <= 0.0:
            if player.has_method("apply_damage"):
                player.apply_damage(attack_damage)
            attack_cooldown = 1.3

        if health < max_health * 0.7 and phase == 1:
            phase = 2
            speed = 3.8
            attack_damage = 26.0
            boss_phase_changed.emit(phase)
        elif health < max_health * 0.35 and phase == 2:
            phase = 3
            speed = 4.6
            attack_damage = 34.0
            boss_phase_changed.emit(phase)
    else:
        velocity.x = move_toward(velocity.x, 0.0, 8.0)
        velocity.z = move_toward(velocity.z, 0.0, 8.0)

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
            player.add_xp(300.0)
        queue_free()

func get_health_ratio() -> float:
    return clamp(health / max_health, 0.0, 1.0)
