#!/usr/bin/env python3
"""MCP Command Bridge — writes commands to unity_commands.json for Unity to execute."""

import json
import sys
import os
import uuid
from datetime import datetime

COMMANDS_FILE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "unity_commands.json")


def read_commands():
    if not os.path.exists(COMMANDS_FILE):
        return {"commands": []}
    for _ in range(3):
        try:
            with open(COMMANDS_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except (IOError, json.JSONDecodeError):
            pass
    return {"commands": []}


def write_commands(data):
    tmp = COMMANDS_FILE + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp, COMMANDS_FILE)


def send_command(cmd_type, **kwargs):
    data = read_commands()
    cmd_id = f"cmd_{uuid.uuid4().hex[:8]}"
    cmd = {
        "id": cmd_id,
        "type": cmd_type,
        "playerIndex": kwargs.get("player_index", 0),
        "steps": kwargs.get("steps", 1),
        "targetTile": kwargs.get("target_tile", 0),
        "status": "pending",
        "result": "",
        "timestamp": datetime.now().isoformat(),
    }
    for k, v in kwargs.items():
        snake_to_camel = "".join(w.capitalize() if i > 0 else w for i, w in enumerate(k.split("_")))
        if snake_to_camel not in cmd:
            cmd[snake_to_camel] = v

    data["commands"].append(cmd)
    write_commands(data)
    return cmd_id


def get_status(cmd_id):
    data = read_commands()
    for cmd in data["commands"]:
        if cmd["id"] == cmd_id:
            return cmd
    return {"error": "not_found", "id": cmd_id}


def purge_completed():
    data = read_commands()
    data["commands"] = [c for c in data["commands"] if c["status"] == "pending" or c["status"] == "processing"]
    write_commands(data)
    return {"purged": True, "remaining": len(data["commands"])}


def main():
    if len(sys.argv) < 2:
        print("Usage: mcp_command_bridge.py <action> [options]")
        print("Actions:")
        print("  move_pawn <player> <steps>           Move player pawn N steps forward")
        print("  move_pawn_to <player> <tile>          Move player pawn directly to tile")
        print("  reset_pawns                           Reset all pawns to start")
        print("  status <cmd_id>                       Get command status")
        print("  init                                  Initialize empty command file")
        print("  purge                                 Remove completed commands")
        print("  list                                  List all commands")
        sys.exit(1)

    action = sys.argv[1]

    if action == "move_pawn":
        player = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        steps = int(sys.argv[3]) if len(sys.argv) > 3 else 1
        cmd_id = send_command("move_pawn", player_index=player, steps=steps)
        print(json.dumps({"id": cmd_id, "action": "move_pawn", "player": player, "steps": steps}))

    elif action == "move_pawn_to":
        player = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        tile = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        cmd_id = send_command("move_pawn_to", player_index=player, target_tile=tile)
        print(json.dumps({"id": cmd_id, "action": "move_pawn_to", "player": player, "tile": tile}))

    elif action == "reset_pawns":
        cmd_id = send_command("reset_pawns")
        print(json.dumps({"id": cmd_id, "action": "reset_pawns"}))

    elif action == "status":
        cmd_id = sys.argv[2] if len(sys.argv) > 2 else ""
        result = get_status(cmd_id)
        print(json.dumps(result, ensure_ascii=False))

    elif action == "init":
        write_commands({"commands": []})
        print(json.dumps({"status": "initialized", "file": COMMANDS_FILE}))

    elif action == "purge":
        result = purge_completed()
        print(json.dumps(result))

    elif action == "list":
        data = read_commands()
        print(json.dumps(data, indent=2, ensure_ascii=False))

    else:
        print(json.dumps({"error": f"Unknown action: {action}"}))
        sys.exit(1)


if __name__ == "__main__":
    main()
