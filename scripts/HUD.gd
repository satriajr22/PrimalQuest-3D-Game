extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var world: Node3D = $World
@onready var hud: CanvasLayer = $HUD

var paused: bool = false

func _ready() -> void:
    if GameManager:
        GameManager.reset()
    if player:
        player.add_to_group("player")
        player.connect("health_changed", Callable(self, "_on_player_health_changed"))
        player.connect("xp_changed", Callable(self, "_on_player_xp_changed"))
        player.connect("level_up", Callable(self, "_on_player_level_up"))
        player.connect("died", Callable(self, "_on_player_died"))
        player.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
    if world:
        world.initialize(player)
    if hud:
        hud.set_player(player)
    _load_saved_progress()

func _load_saved_progress() -> void:
    var data = SaveManager.load_game()
    if data.is_empty():
        return
    var player_data = data.get("player", {})
    if player != null and player.has_method("load_data"):
        player.load_data(player_data)
    var quest_snapshot = data.get("quests", {})
    if quest_snapshot.size() > 0 and QuestSystem:
        QuestSystem.quest_data = quest_snapshot
    if GameManager and data.has("world"):
        var world_data = data.get("world", {})
        GameManager.set_area(world_data.get("location", "City"))

func _on_player_health_changed(value: float) -> void:
    if hud:
        hud.update_health(value)

func _on_player_xp_changed(value: float) -> void:
    if hud:
        hud.update_xp(value)

func _on_player_level_up(level: int) -> void:
    if hud:
        hud.notify("Level Up! Now at level %s" % level)
    if QuestSystem:
        QuestSystem.advance_quest("intro", 1.0)

func _on_player_died() -> void:
    if hud:
        hud.notify("You were defeated. Try again.")

func _on_inventory_changed(items: Array) -> void:
    if hud:
        hud.refresh_inventory(items)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        _toggle_pause()
    elif event.is_action_pressed("inventory"):
        if hud:
            hud.toggle_inventory()
    elif event.is_action_pressed("save"):
        _save_game()
    elif event.is_action_pressed("ultimate"):
        if player and player.has_method("activate_ultimate"):
            player.activate_ultimate()
    elif event.is_action_pressed("special"):
        if player and player.has_method("activate_special"):
            player.activate_special()

func _toggle_pause() -> void:
    paused = !paused
    if hud:
        hud.toggle_pause_menu(paused)
    get_tree().paused = paused

func _save_game() -> void:
    var payload = SaveManager.save_game(player, world, QuestSystem.get_quest_snapshot())
    if hud:
        hud.notify("Progress saved locally.")
    print("Saved: %s" % payload)
