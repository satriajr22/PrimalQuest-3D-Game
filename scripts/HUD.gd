extends CanvasLayer

var player_ref: CharacterBody3D

@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var xp_bar: ProgressBar = $XPBar
@onready var boss_bar: ProgressBar = $BossBar
@onready var quest_label: Label = $QuestLabel
@onready var info_label: Label = $InfoLabel

func set_player(player: CharacterBody3D) -> void:
    player_ref = player
    if player_ref:
        player_ref.connect("health_changed", Callable(self, "_on_health_updated"))
        player_ref.connect("xp_changed", Callable(self, "_on_xp_updated"))

func _on_health_updated(value: float) -> void:
    update_health(value)

func _on_xp_updated(value: float) -> void:
    update_xp(value)

func update_health(value: float) -> void:
    if health_bar:
        health_bar.value = value

func update_experience(value: float) -> void:
    if xp_bar:
        xp_bar.value = value

func update_xp(value: float) -> void:
    if xp_bar:
        xp_bar.value = value

func update_boss(value: float, visible: bool = true) -> void:
    if boss_bar:
        boss_bar.visible = visible
        boss_bar.value = value

func _process(_delta: float) -> void:
    if player_ref and player_ref.has_method("save_data"):
        if health_bar:
            health_bar.max_value = player_ref.max_health
        if stamina_bar:
            stamina_bar.value = player_ref.stamina
        if xp_bar:
            xp_bar.max_value = 100.0
            xp_bar.value = player_ref.xp
        if boss_bar and get_tree().get_first_node_in_group("boss"):
            var boss = get_tree().get_first_node_in_group("boss")
            if boss and boss.has_method("get_health_ratio"):
                boss_bar.visible = true
                boss_bar.value = boss.get_health_ratio() * 100.0

    if QuestSystem:
        var key = "intro"
        var data = QuestSystem.get_quest_snapshot().get(key, {})
        if quest_label and data.has("title"):
            quest_label.text = "Quest: %s" % data["title"]
