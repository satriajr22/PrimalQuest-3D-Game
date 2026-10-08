extends Node

signal world_state_changed(area_name, state)
signal achievement_unlocked(name)

var unlocked_areas: Dictionary = {
    "City": true,
    "Forest": false,
    "Village": false,
    "Cavern": false,
    "Boss Arena": false,
}
var world_state: Dictionary = {
    "kills": 0,
    "fire_totems": 0,
    "boss_defeated": false,
    "current_area": "City",
}
var achievements: Dictionary = {
    "first_blood": false,
    "forest_warden": false,
    "ruin_explorer": false,
    "boss_breaker": false,
}

func set_area(area_name: String) -> void:
    world_state["current_area"] = area_name
    if unlocked_areas.has(area_name):
        unlocked_areas[area_name] = true
    emit_signal("world_state_changed", area_name, world_state)

func register_kill() -> void:
    world_state["kills"] += 1
    if not achievements["first_blood"]:
        achievements["first_blood"] = true
        emit_signal("achievement_unlocked", "first_blood")

func register_boss_defeat() -> void:
    world_state["boss_defeated"] = true
    achievements["boss_breaker"] = true
    emit_signal("achievement_unlocked", "boss_breaker")

func unlock_area(area_name: String) -> void:
    unlocked_areas[area_name] = true

func get_state() -> Dictionary:
    return world_state.duplicate(true)

func reset() -> void:
    unlocked_areas = {
        "City": true,
        "Forest": false,
        "Village": false,
        "Cavern": false,
        "Boss Arena": false,
    }
    world_state = {
        "kills": 0,
        "fire_totems": 0,
        "boss_defeated": false,
        "current_area": "City",
    }
    achievements = {
        "first_blood": false,
        "forest_warden": false,
        "ruin_explorer": false,
        "boss_breaker": false,
    }
