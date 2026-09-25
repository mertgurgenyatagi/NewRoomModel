# NewRoomModel

A 3D model of my ~13 m² studio apartment, built in Blender 5.2 and driven by Claude Code through the [blender-mcp](https://github.com/ahujasid/blender-mcp) server. The goal is to design the room's future look (all current furniture removed, only the mini kitchen stays) before changing anything in real life.

## Status at a glance

| Area | State |
|---|---|
| Style direction | Done, see [STYLE_ANALYSIS.md](STYLE_ANALYSIS.md) |
| Room dimensions | Built at **0.75 m per floor tile**, from the tile-unit plan in [room_plan.png](room_plan.png). The tile size is an estimate, not yet measured |
| Blender shell (walls, window, counter, door) | Done, saved in [room.blend](room.blend) |
| Materials | Done for the existing room, matched to the photos in `actual_room/` |
| Lighting | Done: early-sunset sun with the electric lights off. The electric lights are kept in a hidden collection |
| Exterior | Done: simple urban street outside the window |
| Walkable Godot version | Done: first-person walk-through in `room-godot/`, see the Godot section below |
| Furniture, decor, the new look | **Not started. This is the next phase ("the dream room")** |

## Repository contents

| Path | What it is |
|---|---|
| `PROJECT.md` | This file |
| `room.blend` | The Blender model. `room.blend1` is Blender's automatic backup and is git-ignored |
| `STYLE_ANALYSIS.md` | Style analysis of the 12 mood-board images: palette, materials, light, layout moves, design rules |
| `ROOM_DIMENSIONS.md` | Old photo-derived dimension estimate. Superseded by the plan and the scale below |
| `room_plan.png` | My hand-drawn plan, labelled in floor-tile units. Window side at the top |
| `style_refs/` | 12 mood-board images (Pinterest exports), two of which are identical |
| `actual_room/` | 7 photos of the current room, used for materials, lights and layout |

## Setup

1. Register the MCP server with Claude Code:
   ```
   claude mcp add --scope user blender -- uvx mcp-for-blender
   ```
2. Install the Blender add-on:
   ```
   uvx mcp-for-blender install-addon
   ```
3. In Blender, enable **Interface: MCP for Blender**, press `N` in the 3D viewport, open the **MCP for Blender** tab and click **Start MCP Server**.

The community server runs LLM-generated Python inside Blender with no guards, so save `room.blend` often.

Verified working in this project: Blender 5.2.2 LTS, add-on 1.7, protocol 11, EEVEE renderer, AgX view transform.

## The room

### Scale

`room_plan.png` is labelled in floor-tile units. One unit is assumed to be **0.75 m** (75 x 75 cm tiles). Reasons: it gives about 13 m² in total, the counter comes out at about 1.43 x 0.83 m (I had asked for about 1.35 m wide), and in the photos a tile looks about as wide as the single bed. **Confirm by measuring one tile.** If it is wrong, everything in the model needs rescaling.

### Plan (from `room_plan.png`)

Viewed from above, window at the top:

```
        4.15 units (window wall)
   +------------------------+
   |                        |
   |                        |   right wall 3.5 units
   | left wall              |
   | 4.6 + 2.4 units        |
   |                +-------+
   |                | counter 1.9 x 1.1
   |         +------+-------+
   |         |  0.5 unit step (2.4 units from right wall in total)
   | hall    |
   | 1.75 u  |
   | 2.4 u   |
   |         |
```

| Part | Units | Metres at 0.75 |
|---|---|---|
| Window wall width | 4.15 | 3.11 |
| Main room depth | 4.6 | 3.45 |
| Hall length | 2.4 | 1.8 |
| Hall width | 4.15 - 1.9 - 0.5 = 1.75 | 1.31 |
| Left wall (full length) | 4.6 + 2.4 = 7.0 | 5.25 |
| Counter | 1.9 x 1.1 | 1.43 x 0.83 |
| Step return | 1.9 + 0.5 | 1.8 |

### Assumptions I have not verified

- The tile size of 0.75 m (see Scale).
- Ceiling height 2.6 m (typical, not measured).
- Wall thickness 12 cm (only affects the outside; the interior follows the sketch).
- The entrance door is 0.9 x 2.1 m, at the far end of the hall, against the left wall. The sketch does not show it. The hall is wider than the door, so there is a plain wall pier beside it.
- The window glass is about 2.9 m wide with a 15 cm soffit strip above it. Glass width and height are guesses.
- The bathroom is outside the model (ignored on purpose). It is the solid space to the right of the hall.
- Window faces roughly **west-southwest**, read off a Google Earth bird's-eye view with a heading of 264 degrees. The flat is on the 4th floor, so the room floor is about 12 m above the street.

### What the photos showed (`actual_room/`)

- Large-format floor tiles in a light greige with thin grout, semi-gloss.
- Walls in a fine roughcast plaster, grey-taupe in daylight (`#a7a3a2`). Ceiling and window soffit `#c7c3bd`. The warm colour in the photos comes from the lights.
- Downlights in the ceiling (two in the main room, one in the hall), warm with only a slight orange-yellow tint.
- A panel radiator under the window, a sheer vertical blind plus a heavy brown curtain, and sockets along the walls.
- A white mini kitchen unit: a mini fridge and a sink cabinet with a black speckled worktop and a silver edge strip.
- The entrance door is glossy black with light vertical stripes, and opens inward against the left wall.

## Style direction (summary)

Full detail in [STYLE_ANALYSIS.md](STYLE_ANALYSIS.md).

**Warm, plant-filled, book-heavy "cozy naturalist" studio**: honey-toned wood, cream walls, layered natural textiles, lush greenery and low warm light, with an open shelf unit dividing sleeping from living and working.

Key rules:
- Wood, cream and green are the base. Sage and terracotta are the only accent colours, plus at most one mustard piece.
- Every material natural or natural-looking: wood, linen, wool, jute, rattan, ceramic.
- Many low warm light sources, no single bright ceiling light.
- Keep the window unobstructed. Sheer curtains and low furniture in front of it.
- Use an open shelf unit as the zoning device instead of walls or curtains.
- Furniture low or on visible legs, so the floor reads as continuous.
- Plants at three levels: hanging, floor and shelf/sill.
- Keep a clear walking path of about 60 to 70 cm.

Recommended lean: the bright "sunlit botanical" mood for materials and layout, plus the evening-cozy lighting and sage/terracotta accents.

## Blender model (`room.blend`)

Blender axes: +X to the right of the plan, the window wall at the high-Y end, so the plan reads like the sketch when viewed straight from above. Z is up, the floor is at Z = 0, the ceiling at 2.6 m. Room interior spans X 0 to 3.11 m and Y 0 to 5.25 m.

### Collections and objects

| Collection | Contents |
|---|---|
| `Room` | The shell, the counter, the window blinds, the sun, the cameras |
| `Lights_Day` | The electric lights: three ceiling downlights and their glowing lenses, two fill lights and an overcast-daylight area light. **Excluded from the view layer** (lights off). Enable it to switch them back on |
| `Exterior` | The street and buildings outside the window |

Shell objects in `Room`:

| Object(s) | What |
|---|---|
| `Floor_Main`, `Floor_Hall` | Tile floor |
| `Ceiling_Main`, `Ceiling_Hall` | Ceilings. Hide them in the viewport to see the room from above |
| `Wall_Left`, `Wall_Right`, `Wall_Step`, `Wall_HallRight` | The walls: left 5.25 m, right, the step return, and the hall's right wall |
| `Wall_Window_*`, `Window_Glass`, `Window_Frame_Bottom` | Full-width glazing with piers either side and a soffit above. The glass is clear |
| `Blind_Slat_*` | Sheer vertical blind slats, opened and bunched at the left pier |
| `Wall_Entrance_*`, `Door` | 0.9 x 2.1 m opening at the end of the hall, closed striped black door |
| `Counter_Body`, `Counter_Top` | Plain 1.43 x 0.83 m box, 0.85 m high, floating 6 cm above the floor, black speckled top. No sink, tap, fridge or handles yet |
| `Sun_Sunset` | The early-sunset sun (about 13 degrees above the horizon) |

### Materials (all procedural, based on world position, so they need no UVs)

`Floor` (75 cm tiles), `Wall` (roughcast), `Ceiling`, `Soffit`, `Door`, `Frame`, `Glass`, `CounterWhite`, `CounterTop`, `BlindSheer`, plus the exterior facade materials (`Fac_*`, `Asphalt`, `Sidewalk`).

### Lighting

- **Current state: early sunset, electric lights off.** A warm-orange sun (`Sun_Sunset`, 14 W/m², exposure -0.5) comes from the west-southwest across the street. The sky is a Nishita/multiple-scattering sky with a warm tint. The sun disc itself is hidden.
- The sun is placed so it clears the roofs of the buildings opposite. A tall skyline across the street would block it.
- **Electric-light state:** enable the `Lights_Day` collection. The downlights are warm spots with only a slight orange-yellow tint.

### Exterior

The `Exterior` collection is a simple street about 12 m below the floor and about 14.5 m from the window: sidewalks, road, five buildings opposite and a low hazy skyline behind. The facades are shader-painted windows on boxes, styled after the Vatan Caddesi street photos (cream neoclassical, orange ribbon-window block, small beige, white, pink). There are no trees, cars or street lamps yet. The opposite facades are backlit, which is right for a window facing the sunset.

### Cameras

- `Cam_Window`: from the hall side toward the window (the saved active camera).
- `Cam_Sunset_Room`: from the window corner back into the room.
- `Camera`: an older general-purpose camera near the window.

### Rendering notes

- Renders with `bpy.ops.render.render(write_still=True)` come out washed out or stale if EEVEE is still compiling shaders. Render twice, and keep the 3D viewport in solid mode while doing it.
- The viewport is set to solid shading. Switch to rendered mode by hand for a live look.

### Known issues

- The tile size is unmeasured, so every dimension shares that one uncertainty.
- The counter is a plain box. The real one has a mini fridge, a sink cabinet with two doors and handles, a steel sink and tap, a silver edge strip, and small legs.
- The current furniture is not modelled, on purpose.
- Missing photo details: smoke detector, socket plates, door handle and lock, radiator, curtain.
- The exterior facades read slightly teal because of the blue sky bounce in shade.
- Downlight positions are approximate, placed by eye from the photos.

## Decisions and history

1. Style analysis first, from the mood board, before any modelling.
2. Room dimensions were first derived from photos, using the floor tile grid as a ruler. That took far too long trying to work out the counter's exact position, so I cut it short and asked for a rough result. A tape measure beats photo geometry here.
3. I then sketched the plan myself and asked for a rebuild from it. The sketch replaced the photo-derived numbers.
4. First rebuild came out mirrored, because the sketch's "down" was mapped to +Y (which flips a top-down view). Fixed by flipping the model along Y.
5. The step wall poked 12 cm into the hall. Fixed so it meets the hall wall flush.
6. Materials and lights were matched to the photos. I answered a round of questions to fix the wall, ceiling and floor colours and the floor sheen.
7. The counter was widened, and its base briefly extended to the floor, then that was undone.
8. Sunset lighting and an urban view were added. A first attempt had no sun in the room, because a tall block in the far skyline was cutting off the low sun. The far skyline was lowered.
9. I relabelled the plan in floor-tile units. I estimated 0.75 m per tile and rebuilt the shell at that scale.

## Next steps: the dream room

The foundation (shell, materials, lights, view) is done. From here the work is the new design.

1. Measure one floor tile and confirm the 0.75 m scale. Also confirm ceiling height and window size.
2. Decide the layout: bed, open shelf divider, desk at the window, one seat, rug. Keep a 60 to 70 cm walking path.
3. Build or source the furniture in the honey wood, cream and green palette. Poly Haven, Sketchfab and Poly Pizza assets are available through the MCP server.
4. Materials: honey wood, linen, wool, jute, rattan, ceramic, with sage and terracotta accents.
5. Lighting: keep the sunset state, and add a warm-lamp evening state (many low sources, no single bright ceiling light).
6. Plants at three levels, and decor last.
7. Optional: add the counter details, trees and street lamps outside, and save the daylight look as its own scene.

## Walkable version in Godot (`room-godot/`)

Godot 4.7.2 project that lets me walk around the room in first person. Open it with `Godot_v4.7.2-stable_win64.exe --path room-godot --editor`, or run `main.tscn` (it is the main scene).

- **Controls:** WASD walk, Shift sprint, mouse look, Esc frees the mouse (click to recapture), **L** toggles the electric downlights (off by default).
- **Files:** `main.tscn` (scene), `main.gd` (builds collision for the room meshes, applies the floor tile shader, afternoon daylight sun, light toggle), `player.gd` (walker), `floor_tiles.gdshader` (0.75 m tiles with grout, from world position), `assets/room.glb` (the exported room).
- **Lighting:** plain natural daylight: a neutral white afternoon sun about 40 degrees up from the window side, a normal blue sky, and neutral white ambient light. This differs on purpose from the Blender sunset. SDFGI and sky-coloured ambient were tried and dropped: SDFGI left the interior black, and sky ambient turned everything blue.
- **Getting the room out of Blender:** `tools/export_to_godot.py` replaces the procedural materials with flat colours matching the photos, then exports the room and the exterior as glTF. Run it headless: `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" -b room.blend --python tools/export_to_godot.py`. It does not save `room.blend`. Re-run it after every Blender change, then let Godot re-import.
- **What is lost in the export:** the roughcast wall texture, the striped door, the speckled counter top and the facade windows. They are flat colours in Godot. Floor tiles are recreated by a Godot shader.
- **Godot MCP:** [mkdevkit/godot-mcp](https://github.com/mkdevkit/godot-mcp) (server cloned outside this repo to `Desktop/repos/godot-mcp`, addon in `room-godot/addons/godot_mcp`). Register it with `claude mcp add godot-mcp --scope local --env GODOT_MCP_PORT=6505 -- node <path>/godot-mcp/server/build/index.js`, enable the plugin in Godot, and keep the editor open.
- **MCP quirks found:** `execute_editor_script` is a single-expression evaluator (no statements) and needs an open scene. Game-side node paths must be relative to the scene root (`Player`), not `/root/Main/Player`. `simulate_key` sets `keycode` only, which is why `player.gd` checks both `is_key_pressed` and `is_physical_key_pressed`. If `/mcp` reconnect shows red, an old server copy is probably holding port 6505 (kill the stale node process).
- **Test teleport:** do not drop the player inside the counter or a wall, or the physics pushes them out through the window.

## Notes for future sessions

- Blender MCP tools are used through Claude Code. Always check `get_addon_status` and `get_scene_info` before writing code.
- Never rely on shader node names. Look them up by type.
- The user prefers short, macro-level builds first and corrections in small steps. Do not spend long on photogrammetry again.
- Ask the user short multiple-choice questions when a material or measurement is uncertain. That worked well for colours and finishes.
- Save `room.blend` after each set of changes, and call save twice if `is_dirty` still reads true.
- Do not commit `room.blend1` (Blender's backup file).
