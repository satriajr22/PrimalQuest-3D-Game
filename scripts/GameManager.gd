extends Node

func add_item(items: Array, item_name: String) -> Array:
    if not items.has(item_name):
        items.append(item_name)
    return items

func remove_item(items: Array, item_name: String) -> Array:
    var idx = items.find(item_name)
    if idx != -1:
        items.remove_at(idx)
    return items

func get_inventory_text(items: Array) -> String:
    if items.is_empty():
        return "Inventory\n- Empty"
    var lines: PackedStringArray = ["Inventory"]
    for item in items:
        lines.append("- %s" % str(item))
    return "\n".join(lines)
