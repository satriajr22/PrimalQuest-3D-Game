extends Node

const SAVE_PATH: String = "user://primalquest_save.json"

func save_game(player: Node, world: Node, quests: Dictionary) -> Dictionary:
    var payload = {
        "player": player.has_method("save_data") ? player.save_data() : {},
        "world": {
            "location": player.get("current_area") if player and player.has_method("get") else "City",
            "boss_defeated": false,
        },
        "quests": quests
    }

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(payload, "\t"))
        file.close()

    return payload

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return {}

    var text = file.get_as_text()
    file.close()
    var json = JSON.new()
    var err = json.parse(text)
    if err != OK:
        return {}
    return json.data
