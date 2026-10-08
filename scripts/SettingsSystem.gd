extends Node

func get_inventory_text(items: Array) -> String:
    if items.is_empty():
        return "Inventory\n- Empty"
    var lines: PackedStringArray = ["Inventory"]
    for item in items:
        lines.append("- %s" % str(item))
    return "\n".join(lines)
