# NewRoomModel

A 3D model of my ~13 m² studio apartment, built in Blender 5.2 and driven by Claude Code through the [blender-mcp](https://github.com/ahujasid/blender-mcp) server. The goal is to design the room's future look (all current furniture removed, only the mini kitchen stays) before changing anything in real life.

## Status at a glance

| Area | State |
|---|---|
| Style direction | Done, see [STYLE_ANALYSIS.md](STYLE_ANALYSIS.md) |
| Room dimensions | Rough. The plan sketch in [room_plan.png](room_plan.png) is now the authority. [ROOM_DIMENSIONS.md](ROOM_DIMENSIONS.md) is the older photo-derived estimate |
| Blender shell (walls, window, counter, door) | Built in the live Blender session, **not yet saved as a `.blend` file** |
| Furniture, lighting, materials, decor | Not started |

## Repository contents

| Path | What it is |
|---|---|
| `PROJECT.md` | This file |
| `STYLE_ANALYSIS.md` | Style analysis of the 12 mood-board images: palette, materials, light, layout moves, design rules |
| `ROOM_DIMENSIONS.md` | Room dimensions estimated from photos (superseded where it disagrees with the sketch) |
| `room_plan.png` | My hand-drawn plan with measured dimensions. Window side at the top |
| `style_refs/` | 12 mood-board images (Pinterest exports), two of which are identical |
| `actual_room/` | 7 photos of the current room, used to derive dimensions |

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

The community server runs LLM-generated Python inside Blender with no guards, so save the `.blend` file often.

Verified working in this project: Blender 5.2.2 LTS, add-on 1.7, protocol 11.

## The room

### Authoritative plan (from `room_plan.png`)

Viewed from above, window at the top:

```
        2.6 m (window side)
   +------------------------+
   |                        |
   |                        |   right wall 2.6 m
   | left wall              |
   | 2.6 m                  |
   |                +-------+
   |                | 1 x 0.8 counter
   |         +------+-------+
   |         |  0.5 m step (1.5 m from right wall in total)
   | hall    |
   | 1.1 m   |
   | 1.9 m   |
   |         |
```

- Window wall: 2.6 m wide, full-width floor-to-ceiling glazing.
- Left wall: 2.6 m + 1.9 m = 4.5 m, running the full length.
- Right wall: 2.6 m.
- At the bottom of the main room a wall steps in from the right: 1 m (beside the counter) + 0.5 m = 1.5 m.
- The hall is therefore 2.6 - 1.5 = 1.1 m wide and runs the remaining 1.9 m down the left side to the entrance.
- The counter is drawn as a 1 m x 0.8 m rectangle in the corner between the right wall and the step wall.

### Assumptions I have not verified

- Ceiling height 2.6 m (typical, not measured).
- Wall thickness 12 cm (only affects the outside; the interior follows the sketch).
- The entrance door is 0.9 x 2.1 m and sits at the far end of the hall, at the left. The sketch does not show the door.
- The 1 m x 0.8 m rectangle is the kitchen counter. The photos suggested a deeper-than-usual counter is unlikely (about 0.55 m), so the 0.8 m may be something else.
- The window glass is about 2.4 m wide with a 15 cm soffit strip above it, from the photos.
- The bathroom is outside the model (ignored on purpose). It is the solid space to the right of the hall.

### What the photos showed (`actual_room/`)

- Large-format floor tiles, about 60 x 60 cm (this scale fitted the bed at about 1.93 m long and the desk at about 53 cm deep).
- A panel radiator under the window, a sheer blind plus a heavy curtain, and sockets along the walls.
- A white mini kitchen unit: a mini fridge and a sink cabinet with a dark speckled worktop.
- The entrance door is glossy black with light vertical stripes and opens inward against the left wall.
- The photo-derived width (about 2.55 m) is consistent with the sketch (2.6 m). The photo-derived length (about 4.2 m) is shorter than the sketch's 4.5 m, so trust the sketch.

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

## Blender model

### Current build (the "macro shell")

Everything lives in a collection named `Room`. Blender axes: +X to the right of the plan, the window wall at the high-Y end, so the plan reads like the sketch when viewed straight from above.

| Object(s) | What |
|---|---|
| `Floor_Main`, `Floor_Hall` | Grey slabs, no tile lines |
| `Ceiling_Main`, `Ceiling_Hall` | Hidden in the viewport so the room can be seen from above |
| `Wall_Left` | Full 4.5 m |
| `Wall_Right` | 2.6 m |
| `Wall_Step` | 1.5 m return at the end of the main room |
| `Wall_HallRight` | 1.1 m hall's right wall, 1.9 m long |
| `Wall_Window_*`, `Window_Glass`, `Window_Frame_Bottom` | Full-width glazing about 2.4 m wide, piers either side, soffit above |
| `Wall_Entrance_*`, `Door` | 0.9 x 2.1 m opening at the end of the hall, closed black door slab |
| `Counter_Body`, `Counter_Top` | Plain 1.0 x 0.8 m box, 0.88 m high, dark top. No sink, tap or fridge detail on purpose |
| Area light | One area light above the room |

This was deliberately kept macro: no faucet, handles, radiator, curtains or trim.

### Known issues

- The scene has not been saved to a `.blend` file. The build script lived in the Blender session only.
- The default camera was deleted and none has been added yet.
- The counter and door positions are placeholders.

## Decisions and history

1. Style analysis first, from the mood board, before any modelling.
2. Room dimensions were first derived from photos, using the floor tile grid as a ruler. That took far too long trying to work out the counter's exact position, so I cut it short and asked for a rough result. A tape measure beats photo geometry here.
3. I then sketched the plan myself and asked for a rebuild from it. The sketch replaced the photo-derived numbers.
4. First rebuild came out mirrored, because the sketch's "down" was mapped to +Y (which flips a top-down view). Fixed by flipping the model along Y.
5. The step wall poked 12 cm into the hall. Fixed so it meets the hall wall flush.

## Next steps

1. Save the model as a `.blend` file (decide where it lives, and whether to commit it).
2. Tape-measure and confirm: ceiling height, window glass width and height, entrance door position, counter depth and position.
3. Add a camera and decide on a hero view.
4. Layout the furniture: bed, open shelf divider, desk at the window, one seat, rug.
5. Materials and lighting: honey wood, cream, sage and terracotta accents, warm lamps.
6. Plants and decor last.

## Notes for future sessions

- Blender MCP tools are used through Claude Code. Always check `get_addon_status` and `get_scene_info` before writing code.
- Never rely on shader node names. Look them up by type.
- The user prefers short, macro-level builds first and corrections in small steps. Do not spend long on photogrammetry again.
