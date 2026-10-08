extends Node

signal quest_updated(title, description, progress)

var quest_data = {
    "intro": {"title": "Awakening", "description": "Reach the ruins and prepare for survival.", "progress": 0.0, "goal": 1.0},
    "forest": {"title": "Forest Whisper", "description": "Defeat the outpost enemies in the forest.", "progress": 0.0, "goal": 5.0},
    "ruins": {"title": "Ruins of the Old City", "description": "Explore the abandoned village and recover the relics.", "progress": 0.0, "goal": 3.0},
    "boss": {"title": "The Core Warden", "description": "Defeat the final guardian.", "progress": 0.0, "goal": 1.0}
}

func update_quest(key: String, value: float) -> void:
    if quest_data.has(key):
        quest_data[key]["progress"] = clamp(value, 0.0, quest_data[key]["goal"])
        emit_signal("quest_updated", quest_data[key]["title"], quest_data[key]["description"], quest_data[key]["progress"] / quest_data[key]["goal"])

func get_quest_snapshot() -> Dictionary:
    return quest_data.duplicate(true)
