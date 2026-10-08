extends Node

signal quest_updated(title, description, progress)

var quest_data = {
    "intro": {"title": "Awakening", "description": "Reach the old city and secure your footing.", "progress": 0.0, "goal": 1.0},
    "forest": {"title": "Forest Whisper", "description": "Clear the forest outposts.", "progress": 0.0, "goal": 5.0},
    "village": {"title": "Abandoned Village", "description": "Explore ruined homes and recover the relics.", "progress": 0.0, "goal": 3.0},
    "boss": {"title": "The Core Warden", "description": "Defeat the guardian of the mountain vault.", "progress": 0.0, "goal": 1.0}
}

func update_quest(key: String, progress: float) -> void:
    if not quest_data.has(key):
        return
    quest_data[key]["progress"] = clamp(progress, 0.0, quest_data[key]["goal"])
    var amount = quest_data[key]["progress"] / quest_data[key]["goal"]
    emit_signal("quest_updated", quest_data[key]["title"], quest_data[key]["description"], amount)

func get_quest_snapshot() -> Dictionary:
    return quest_data.duplicate(true)
