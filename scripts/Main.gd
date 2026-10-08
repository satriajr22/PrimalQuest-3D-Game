extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var world: Node3D = $World
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
    if player:
        player.connect("health_changed", Callable(self, "_on_player_health_changed"))
        player.connect("xp_changed", Callable(self, "_on_player_xp_changed"))
        player.connect("level_up", Callable(self, "_on_player_level_up"))
        player.connect("died", Callable(self, "_on_player_died"))
    if world:
        world.initialize(player)
    if hud:
        hud.set_player(player)

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
