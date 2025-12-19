# Haxe + TIC-80 Template (Lua cart)

[中文](README.md) | **English**

This repo is a template project to write game logic in **Haxe** and run it in **TIC-80** as a Lua cart.

- **Target**: TIC-80 (Lua script)
- **Workflow (Extract + Merge)**:
  - Write game logic in Haxe (Snake is the hello-world example)
  - Build outputs Lua to `build/gen.lua`
  - The merge tool does two things:
    - **Extract**: if `cart/main.lua` exists, extract its TIC-80 data sections into `assets/assets.lua` (recommended to commit)
    - **Merge**: generate `cart/main.lua` from `assets/assets.lua` + `build/gen.lua` (TIC-80 always opens this file)

Snake is provided as the **Hello World**.

## Project layout

- `src/`
  - `Main.hx`: game entry (currently Snake)
  - `tic/Tic.hx`: TIC-80 API externs (type-checking on Haxe side)
- `tools/`
  - `Build.hx`: Extract + Merge tool
  - `EnsureDirs.hx`: compile-time macro to ensure output dirs exist
- `assets/`
  - `assets.lua`: TIC-80 data sections (source-of-truth for assets, recommended to commit)
- `cart/`
  - `main.lua`: runnable TIC-80 cart (generated, ignored by default)
- `build/`
  - `gen.lua`: Haxe Lua output (generated, ignored by default)

## Requirements

- Install **Haxe** (4.x recommended)
  - `haxe -version`
- Install **TIC-80**

> Note: TIC-80 runs Lua in a sandbox. Many libraries / modules are not available (e.g. `os`, arbitrary `require`). This template injects a small shim during merge to keep the Haxe runtime compatible.

## Build (Windows / PowerShell)

Run in the repo root:

1) **Compile Haxe -> Lua (intermediate output)**
```powershell
haxe build.hxml
```
This generates:
- `build/gen.lua`

2) **Merge into a runnable TIC-80 cart**
```powershell
haxe merge.hxml
```
This step:
- extracts data sections from `cart/main.lua` into `assets/assets.lua` (if `cart/main.lua` exists)
- generates a new `cart/main.lua` from `assets/assets.lua` + `build/gen.lua`

> By default, `.gitignore` ignores `build/` and `cart/`. After the first clone, you need to run `haxe build.hxml` + `haxe merge.hxml` to generate `cart/main.lua`.

## Run in TIC-80

In the TIC-80 console:

```lua
load cart/main.lua
run
```

## Workflow details

### Extract + Merge (used by this template)

- **Source of truth for assets**: `assets/assets.lua`
- **What TIC-80 runs**: `cart/main.lua`
  - regenerated every time you run `haxe merge.hxml`

### Recommended way to edit assets in TIC-80

1. Generate the cart first:
   - `haxe build.hxml`
   - `haxe merge.hxml`
2. Open `cart/main.lua` in TIC-80, edit assets (data sections) and save
3. Sync assets back into the repo:
   - `haxe merge.hxml`

## Snake (Hello World)

- **Controls**:
  - Up: `btnp(0)`
  - Down: `btnp(1)`
  - Left: `btnp(2)`
  - Right: `btnp(3)`
- **Rules**:
  - Eat food to grow and increase score
  - Hit wall or self -> reset
- **Rendering**:
  - Black background (`cls(0)`)
  - Snake body uses `spr(33, ...)`
  - Food uses `spr(34, ...)`

## A typical iteration (assets + code)

Example: add/edit a sprite in TIC-80 and then use it from Haxe.

1) In TIC-80:
- `load cart/main.lua`
- edit/save assets (e.g. create sprite #34)

2) Sync assets back to the repo:
```powershell
haxe merge.hxml
```

3) Modify Haxe code and rebuild:
```powershell
haxe build.hxml
haxe merge.hxml
```

## Git recommendations

Recommended to commit:
- `src/`
- `tools/`
- `build.hxml`, `merge.hxml`
- `assets/assets.lua`
- `README.md`, `README_EN.md`

Recommended to ignore (see `.gitignore`):
- `build/`
- `cart/`
