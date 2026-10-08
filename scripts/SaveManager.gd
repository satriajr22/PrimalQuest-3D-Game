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
        player_ref.connect("health_changed", Callable(self, "update_health"))
        player_ref.connect("xp_changed", Callable(self, "update_xp"))
    _refresh_hud()

func _refresh_hud() -> void:
    if player_ref and health_bar:
        health_bar.max_value = player_ref.max_health
    if player_ref and stamina_bar:
        stamina_bar.max_value = player_ref.stamina_max
    if player_ref and xp_bar:
        xp_bar.max_value = 100.0

func update_health(value: float) -> void:
    if health_bar:
        health_bar.value = value

func update_stamina(value: float) -> void:
    if stamina_bar:
        stamina_bar.value = value

func update_xp(value: float) -> void:
    if xp_bar:
        xp_bar.value = value

func update_boss(value: float, visible: bool = true) -> void:
    if boss_bar:
        boss_bar.visible = visible
        boss_bar.value = value

func _process(_delta: float) -> void:
    if player_ref:
        update_health(player_ref.health)
        update_stamina(player_ref.stamina)
        update_xp(player_ref.xp)
        if health_bar:
            health_bar.max_value = player_ref.max_health
        if stamina_bar:
            stamina_bar.max_value = player_ref.stamina_max

    if quest_label:
        var quest_data = QuestSystem.get_quest_snapshot()
        if quest_data.size() > 0:
            var first_key = quest_data.keys()[0]
            var quest = quest_data[first_key]
            quest_label.text = "Quest: %s" % quest["title"]

    var boss = get_tree().get_first_node_in_group("boss")
    if boss and boss.has_method("get_health_ratio"):
        update_boss(boss.get_health_ratio() * 100.0, true)
    else:
        update_boss(0.0, false)
