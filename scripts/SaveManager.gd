extends Node

const SAVE_PATH = "user://primalquest_save.json"

func save_game(player: Node, world: Node, quests: Dictionary) -> void:
    var payload = {
        "player": player.save_data() if player.has_method("save_data") else {},
        "world": {
            "progress": "forest_clear",
            "boss_defeated": false
        },
        "quests": quests
    }
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(payload, "\t"))
        file.close()

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        return {}
    var text = file.get_as_text()
    file.close()
    var json = JSON.new()
    var err = json.parse(text)
    if err != OK:
        return {}
    return json.data
