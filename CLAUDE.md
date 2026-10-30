# LangRPG

## Stack
- Godot 4 (project targets 4.7, GL Compatibility renderer).
- Typed GDScript only: annotate variables, parameters, and return types
  (`var speed: float = 120.0`, `func move(dir: Vector2) -> void:`).

## Folders
- `scenes/` — `.tscn` scene files
- `scripts/` — `.gd` scripts
- `assets/` — art, audio, fonts, and other imported resources

## Game structure
Top-down, screen-by-screen exploration in the style of 90s adventure games, for students.
- `scenes/main.tscn` + `scripts/main.gd` — entry point; wires everything together and slides the
  camera one room at a time. Also defines the input actions (`move_*`, `interact`).
- `scripts/world.gd` — the overworld. Rooms are 16x11 tiles of 16px, written as text maps in `ROOMS`
  (legend at the top of the file); NPCs and their dialogue live in `NPCS`. Tile art is placeholder,
  painted in code.
- `scripts/player.gd`, `scripts/npc.gd`, `scripts/dialogue_box.gd` — with matching scenes.
- Internal resolution is 256x192 (16px HUD bar on top), scaled up with nearest filtering.

## Checking for errors
After changing any script, run Godot headless and fix every error it reports before moving on:

```bash
GODOT="/c/Users/User/Godot/4.7.2/Godot_v4.7.2-stable_win64_console.exe"
"$GODOT" --headless --path . --import
"$GODOT" --headless --check-only --script scripts/<file>.gd
"$GODOT" --headless --path . --quit-after 180   # run the game briefly to catch runtime errors
```

Godot 4.7.2 is installed at `C:\Users\User\Godot\4.7.2\` (use the `_console.exe` for headless runs).

## Git
- Commit after each working feature (only once the headless check passes).
- Remote: https://github.com/fredpoole/langrpg (branch `main`).
