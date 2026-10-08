extends Node

const SAVE_PATH: String = "user://primalquest_save.json"

func save_game(player: Node, world: Node, quests: Dictionary) -> Dictionary:
    var player_data = {}
    if player and player.has_method("save_data"):
        player_data = player.save_data()
    
    var payload = {
        "player": player_data,
        "world": {"location": player_data.get("current_area", "City") if player_data else "City", "boss_defeated": false},
        "quests": quests,
        "timestamp": Time.get_ticks_msec()
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

func delete_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
