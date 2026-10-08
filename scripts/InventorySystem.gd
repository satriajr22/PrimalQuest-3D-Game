extends Node

signal quest_updated(title, description, progress)
signal quest_completed(quest_key)

var quest_data = {
    "intro": {"title": "Awakening", "description": "Reach the old city and secure your footing.", "progress": 0.0, "goal": 1.0, "complete": false},
    "forest": {"title": "Forest Whisper", "description": "Clear the forest outposts.", "progress": 0.0, "goal": 5.0, "complete": false},
    "village": {"title": "Abandoned Village", "description": "Explore ruined homes and recover the relics.", "progress": 0.0, "goal": 3.0, "complete": false},
    "boss": {"title": "The Core Warden", "description": "Defeat the guardian of the mountain vault.", "progress": 0.0, "goal": 1.0, "complete": false}
}
var active_key: String = "intro"

func set_active_quest(key: String) -> void:
    if quest_data.has(key):
        active_key = key

func update_quest(key: String, progress: float) -> void:
    if not quest_data.has(key):
        return
    quest_data[key]["progress"] = clamp(progress, 0.0, quest_data[key]["goal"])
    if quest_data[key]["progress"] >= quest_data[key]["goal"]:
        quest_data[key]["complete"] = true
        emit_signal("quest_completed", key)
    var amount = quest_data[key]["progress"] / quest_data[key]["goal"]
    emit_signal("quest_updated", quest_data[key]["title"], quest_data[key]["description"], amount)

func advance_quest(key: String, delta: float = 1.0) -> void:
    if not quest_data.has(key):
        return
    update_quest(key, quest_data[key]["progress"] + delta)

func get_current_quest() -> Dictionary:
    if quest_data.has(active_key):
        return quest_data[active_key]
    return {}

func get_quest_snapshot() -> Dictionary:
    return quest_data.duplicate(true)

func reset_all() -> void:
    for key in quest_data.keys():
        quest_data[key]["progress"] = 0.0
        quest_data[key]["complete"] = false
    active_key = "intro"

func claim_quest_reward(key: String) -> void:
    if quest_data.has(key):
        quest_data[key]["complete"] = true
        emit_signal("quest_completed", key)
