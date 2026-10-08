extends Node

var world: Node
var player: CharacterBody3D

var inventory: Array = []
var world_progress: Dictionary = {"forest": false, "ruins": false, "boss": false}

func _ready() -> void:
    add_to_group("player")

func add_item(item_name: String) -> void:
    inventory.append(item_name)

func add_xp(amount: float) -> void:
    if player and player.has_method("add_xp"):
        player.add_xp(amount)

func save_state() -> Dictionary:
    var result = {"inventory": inventory, "world_progress": world_progress}
    if player and player.has_method("save_data"):
        result["player"] = player.save_data()
    return result

func load_state(data: Dictionary) -> void:
    if data.has("inventory"):
        inventory = data["inventory"]
    if data.has("world_progress"):
        world_progress = data["world_progress"]
    if player and player.has_method("load_data") and data.has("player"):
        player.load_data(data["player"])
