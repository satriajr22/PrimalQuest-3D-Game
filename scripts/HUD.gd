extends CanvasLayer

var player_ref: CharacterBody3D
var inventory_panel: Panel
var inventory_label: Label
var pause_panel: Panel
var pause_label: Label
var notification_label: Label

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
        player_ref.connect("inventory_changed", Callable(self, "refresh_inventory"))
    _build_inventory_panel()
    _build_pause_panel()
    _build_notification_label()
    _refresh_hud()

func _build_inventory_panel() -> void:
    if has_node("InventoryPanel"):
        inventory_panel = get_node("InventoryPanel")
        inventory_label = inventory_panel.get_node("InventoryLabel")
        return

    inventory_panel = Panel.new()
    inventory_panel.name = "InventoryPanel"
    inventory_panel.position = Vector2(40, 140)
    inventory_panel.size = Vector2(340, 280)
    inventory_panel.visible = false
    add_child(inventory_panel)

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.09, 0.11, 0.15, 0.88)
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.45, 0.85, 1.0, 0.76)
    inventory_panel.add_theme_stylebox_override("panel", style)

    inventory_label = Label.new()
    inventory_label.name = "InventoryLabel"
    inventory_label.position = Vector2(18, 18)
    inventory_label.size = Vector2(300, 240)
    inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    inventory_label.text = "Inventory\n- Rusty Blade\n- Field Kit"
    inventory_panel.add_child(inventory_label)

func _build_pause_panel() -> void:
    if has_node("PausePanel"):
        pause_panel = get_node("PausePanel")
        pause_label = pause_panel.get_node("PauseLabel")
        return

    pause_panel = Panel.new()
    pause_panel.name = "PausePanel"
    pause_panel.anchor_left = 0.5
    pause_panel.anchor_top = 0.5
    pause_panel.anchor_right = 0.5
    pause_panel.anchor_bottom = 0.5
    pause_panel.offset_left = -160.0
    pause_panel.offset_top = -120.0
    pause_panel.offset_right = 160.0
    pause_panel.offset_bottom = 120.0
    pause_panel.visible = false
    add_child(pause_panel)

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.08, 0.09, 0.12, 0.9)
    pause_panel.add_theme_stylebox_override("panel", style)

    pause_label = Label.new()
    pause_label.name = "PauseLabel"
    pause_label.position = Vector2(24, 24)
    pause_label.size = Vector2(260, 180)
    pause_label.text = "Paused\n\n[Esc] Resume\n[F5] Save\n[I] Inventory"
    pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    pause_panel.add_child(pause_label)

func _build_notification_label() -> void:
    if has_node("NotificationLabel"):
        notification_label = get_node("NotificationLabel")
        return

    notification_label = Label.new()
    notification_label.name = "NotificationLabel"
    notification_label.anchor_left = 0.5
    notification_label.anchor_right = 0.5
    notification_label.offset_left = -200.0
    notification_label.offset_right = 200.0
    notification_label.offset_top = 20.0
    notification_label.offset_bottom = 60.0
    notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    notification_label.visible = false
    add_child(notification_label)

func _refresh_hud() -> void:
    if player_ref and health_bar:
        health_bar.max_value = player_ref.max_health
    if player_ref and stamina_bar:
        stamina_bar.max_value = player_ref.stamina_max
    if player_ref and xp_bar:
        xp_bar.max_value = 100.0
    refresh_inventory(player_ref.inventory if player_ref else [])

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

func refresh_inventory(items: Array) -> void:
    if inventory_label == null:
        return
    if items is Array and items.size() > 0:
        inventory_label.text = "Inventory\n" + "\n".join(items.map(func(item): return "- %s" % item))
    else:
        inventory_label.text = "Inventory\n- Empty"

func notify(message: String) -> void:
    if notification_label:
        notification_label.text = message
        notification_label.visible = true
        notification_label.modulate.a = 1.0
        var tween = create_tween()
        tween.tween_property(notification_label, "modulate:a", 0.0, 1.2)
        tween.tween_callback(func(): notification_label.visible = false)

func toggle_inventory() -> void:
    if inventory_panel:
        inventory_panel.visible = !inventory_panel.visible

func toggle_pause_menu(value: bool) -> void:
    if pause_panel:
        pause_panel.visible = value

func _process(_delta: float) -> void:
    if player_ref:
        update_health(player_ref.health)
        update_stamina(player_ref.stamina)
        update_xp(player_ref.xp)
        if health_bar:
            health_bar.max_value = player_ref.max_health
        if stamina_bar:
            stamina_bar.max_value = player_ref.stamina_max

    if quest_label and QuestSystem:
        var data = QuestSystem.get_quest_snapshot()
        if data.size() > 0:
            var keys = data.keys()
            if keys.size() > 0:
                var first_key = keys[0]
                var quest = data[first_key]
                quest_label.text = "Quest: %s" % quest["title"]

    var boss = get_tree().get_first_node_in_group("boss")
    if boss and boss.has_method("get_health_ratio"):
        update_boss(boss.get_health_ratio() * 100.0, true)
    else:
        update_boss(0.0, false)
