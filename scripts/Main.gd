extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var world: Node3D = $World
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
    if player:
        player.add_to_group("player")
        player.connect("health_changed", Callable(self, "_on_player_health_changed"))
        player.connect("xp_changed", Callable(self, "_on_player_xp_changed"))
        player.connect("level_up", Callable(self, "_on_player_level_up"))
        player.connect("died", Callable(self, "_on_player_died"))

    if world:
        world.initialize(player)

    if hud:
        hud.set_player(player)

    if InputMap.has_action("pause"):
        InputMap.action_add_event("pause", InputEventKey.new())

func _on_player_health_changed(value: float) -> void:
    if hud:
        hud.update_health(value)

func _on_player_xp_changed(value: float) -> void:
    if hud:
        hud.update_xp(value)

func _on_player_level_up(level: int) -> void:
    print("Level Up: %s" % level)

func _on_player_died() -> void:
    print("Player Defeated")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        print("Pause toggled")

    if event.is_action_pressed("interact"):
        var collectibles = get_tree().get_nodes_in_group("collectibles")
        for item in collectibles:
            if item.global_position.distance_to(player.global_position) < 3.5:
                item.queue_free()
                if player.has_method("add_xp"):
                    player.add_xp(15.0)
                break

    if event.is_action_pressed("save"):
        var save_data = SaveManager.save_game(player, world, QuestSystem.get_quest_snapshot())
        print("Game saved")
