# LangRPG

## Stack
- Godot 4 (project targets 4.7, GL Compatibility renderer).
- Typed GDScript only: annotate variables, parameters, and return types
  (`var speed: float = 120.0`, `func move(dir: Vector2) -> void:`).

## Folders
- `scenes/` — `.tscn` scene files
- `scripts/` — `.gd` scripts
- `assets/` — art, audio, fonts, and other imported resources

## Checking for errors
After changing any script, run Godot headless and fix every error it reports before moving on:

```bash
"$GODOT" --headless --path . --import
"$GODOT" --headless --check-only --script scripts/<file>.gd
```

`$GODOT` is the path to the Godot 4 executable (set it as an environment variable,
e.g. `C:\path\to\Godot_v4.x-stable_win64_console.exe`).

## Git
- Commit after each working feature (only once the headless check passes).
- Remote: https://github.com/fredpoole/langrpg (branch `main`).
