# NewRoomModel

A 3D model of my studio apartment (built as ~13 m², but the real floor tile turned out smaller, so the real room is about 9.9 m², see Scale), built in Blender 5.2 and driven by Claude Code through the [blender-mcp](https://github.com/ahujasid/blender-mcp) server, plus a Godot 4.7 project that lets me walk around it in first person. The goal is to design the room's future look (all current furniture removed, only the mini kitchen stays) before changing anything in real life.

## Status at a glance

| Area | State |
|---|---|
| Style direction | Done, see [STYLE_ANALYSIS.md](STYLE_ANALYSIS.md) |
| Room dimensions | Built at **0.75 m per floor tile**, from the tile-unit plan in [room_plan.png](room_plan.png). The tile was then measured at **0.652 m**, so the model is about 13% too big in plan. **Deliberately kept as it is for now** (decision 2026-09-26). Ceiling height and window size are still unmeasured |
| Blender shell (walls, window, counter, door) | Done, saved in [room.blend](room.blend), with photo details added (skirting, window frame, radiator, curtain, door handle, sockets, counter details, street trees, lamps and cars) |
| Materials | Done for the existing room, matched to the photos in `actual_room/` |
| Lighting | Blender: early-sunset sun with the electric lights off (the lights are in a hidden collection). Godot: its own natural, dreamy late-afternoon look with baked bounce light |
| Exterior | Done: simple urban street outside the window |
| Walkable Godot version | Done: first-person walk-through in `room-godot/` with collision, custom surface shaders, baked GI, haze, bloom and vignette. See the Godot section below |
| Floor (the real plan) | **Done, the book is closed.** Rolled dark-walnut wood-print vinyl sheet (muşamba) laid loose over the tile, now a 3 m wide roll of about 15 m². Modelled in Godot only. `room.blend` still has the old tile material. Nothing is bought yet. See "Real-life floor plan" |
| Rug | Leaning toward a round 120 cm polypropylene sisal-look rug (ARTİSAN Concept TYANA), placed as a guess in Godot. Not bought. The upkeep filters are in `rug_spec_tags.txt` |
| Furniture, decor, the new look | **Not started. This is the next phase ("the dream room")** |

## Repository contents

| Path | What it is |
|---|---|
| `PROJECT.md` | This file |
| `room.blend` | The Blender model. `room.blend1` is Blender's automatic backup and is git-ignored |
| `room-godot/` | The Godot 4.7 project: the walkable room, shaders, lighting and the Godot MCP addon |
| `tools/` | Blender scripts: `add_room_detail.py` (adds detail to `room.blend`) and `export_to_godot.py` (exports to glTF for Godot) |
| `STYLE_ANALYSIS.md` | Style analysis of the 12 mood-board images: palette, materials, light, layout moves, design rules |
| `ROOM_DIMENSIONS.md` | Old photo-derived dimension estimate. Superseded by the plan and the scale below |
| `room_plan.png` | My hand-drawn plan, labelled in floor-tile units. Window side at the top |
| `new-rug.png` | Product photo of the round rug now in the Godot model (background already transparent). Cropped copy: `room-godot/assets/rug_round.png` |
| `rug-model.webp` | Top-down photo of the earlier striped rug, no longer used. Cropped copy: `room-godot/assets/rug.png` |
| `rug_spec_tags.txt` | Shop-filter checklist for choosing a rug, purged down to the tags that affect low maintenance |
| `rugs.txt` | Two saved Trendyol filter searches (one for "halı", one for "kilim") with the upkeep filters already applied |
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

`room_plan.png` is labelled in floor-tile units. One unit is assumed to be **0.75 m** (75 x 75 cm tiles). Reasons: it gives about 13 m² in total, the counter comes out at about 1.43 x 0.83 m (I had asked for about 1.35 m wide), and in the photos a tile looks about as wide as the single bed. That was the assumption the model was built on. It has since been measured, see below.

**Measured (2026-09-26): 2.7 tiles = 1.76 m, so one tile is 0.652 m, not 0.75 m.** The plan units are therefore about 13% smaller, and the model (still built at 0.75 m) is too big: the room is really about 2.71 m wide and 3.0 m deep (hall 1.57 m long), about 9.9 m² in total, and the counter about 1.24 x 0.72 m. Heights (ceiling, door, counter height) are not affected by the tile. **Decision (2026-09-26): keep the model at 0.75 m for now, do not rescale.** Everything in this file that quotes metres for the room (the plan table, the Blender section, the Godot rug and planks) is at the old 0.75 m scale. Doing it properly would mean rebuilding the walls and floor at the new plan size and repositioning the details (door, window, radiator and skirting keep their real sizes, so it is not a uniform scale), then re-exporting and re-baking the GI. Take real measurements with a tape before buying anything sized to the room.

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

- The tile size: the model uses 0.75 m but 2.7 tiles were measured as 1.76 m, so about 0.652 m (see Scale). The 1.76 m measurement is the only real one so far. The room width and depth themselves are still derived, not tape-measured.
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

- The model is built at 0.75 m per tile, but the tile is about 0.652 m, so every plan dimension is about 13% too large (kept on purpose, see Scale).
- The counter now has fridge and cabinet doors, handles, a steel sink and tap, an edge strip and legs, but it is still simple geometry. The real one has more detail.
- The current furniture is not modelled, on purpose.
- Photo details still approximate: radiator, curtain and door handle shapes and positions were placed by eye.
- The far skyline outside is plain boxes, and the opposite facades are flat colour with window grids.
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
9. I relabelled the plan in floor-tile units. I estimated 0.75 m per tile and rebuilt the shell at that scale. I decided to keep 0.75 m.
10. I chose the Godot MCP by searching for candidates, picked [mkdevkit/godot-mcp](https://github.com/mkdevkit/godot-mcp), and built the walkable room. The Blender MCP was not needed for the export, because Blender can run headless.
11. First Godot look was flat and grey. I had flattened every procedural material to a plain colour in the export and had no bounce light. I told the user the causes in this order: lighting, lost materials, then a thin model.
12. Forced sunset lighting in Godot felt unnatural, so I switched to natural daylight. SDFGI left the interior black twice and was dropped.
13. I added the model detail, world-position surface shaders (plaster, door, worktop, facades), then a satin shader with real reflections, beveled edges, a reflection probe and baked VoxelGI.
14. Art direction from the user: natural (not forced sunset), stylish like a beautiful indie game, a subtle "romantic dream" mood, and surfaces that respond to light like real objects. Furniture was deliberately left out for now.
15. The tile floor read as a bathroom (visible grid, semi-gloss, cool greige). Constraints for the fix, in priority order: waterproof with no crumb traps (very high), no power tools and easy install (high), removable after about 2 years (medium), price with a hard ceiling of 100 USD (a gate, not a weight), feel last. Ten options were scored in an artifact. The winner was a matte, embossed, foam-backed oak-print PVC sheet (muşamba), loose-laid over the tile with tape at the edges only. It has no joints, so nothing traps crumbs or water. SPC click vinyl, loose-lay LVT, deck tiles and glued oak all failed the 100 USD ceiling. Laminate was rejected because its core swells with water, EVA foam mats and bamboo because their seams and slats trap crumbs.
16. The 100 USD ceiling was dropped **for the bare flooring only** (not for the rug or furniture). The sheet stayed the winner anyway, because it is the only option with no seams, and LVT was not reopened. The wood tone went from honey oak to a dark reddish-brown walnut ("koyu kahve" or "ceviz desenli"), matched by colour to a reference photo. Dark matte floors show dust and crumbs more, which cuts against the maintenance priority, and this was accepted.
17. The Godot floor was made to look like the real thing (planks, printed joints, matte, no seam), the sun was softened after "way too sharp" (bigger sun disc, blurrier shadows, single shadow cascade, a bit more ambient light, flat contrast), and the game now starts full screen. The sun softening also fixed a line that followed the camera across the floor, which was the boundary between the two shadow cascades showing up on the grainy floor. That was a diagnosis, not something confirmed by looking.
18. Rug: the upkeep preference was set at "priority number one" (wash rarely, a stain must not ruin it), and the 105-tag spec list was purged down to the 36 that affect it. The shop filters chosen were: backing (felt, woven, knit, cotton, polyester, polypropylene, chenille or suede, never latex, rubber, PVC dots or faux leather, because those stain vinyl), machine-made, no fringe, thin pile, polypropylene, and multicolour or beige. A striped vintage kilim was modelled first, purely for the look, and dropped because it likely fails the filters (title says kaymaz and şönil). The choice moved to a round 120 cm polypropylene sisal-look rug, which passes every filter.
19. The tile was measured: 2.7 tiles = 1.76 m, so 0.652 m per tile, not 0.75 m. The model is about 13% too big in plan. It was **decided to keep the model as it is** and not rebuild it. Real consequence for the floor: the real room is about 2.71 m wide, so a 3 m roll is enough (no more 4 m roll).

## Real-life floor plan (rolled vinyl over the tile)

**Status (2026-09-26):** move-in is at least a month away, so **nothing is bought yet**. Do not shop until about a week or two before moving in. Budget is no longer a constraint **for the bare flooring only** (the earlier 100 USD ceiling was dropped for it on 2026-09-26). It is not dropped for anything else, such as the rug or furniture.

**What it is:** one big sheet of wood-look plastic (muşamba) unrolled over the existing tile, trimmed with a knife and taped at the edges. Nothing is glued and no power tools are used. To undo it, peel the tape and roll it up.

### Shopping list

| # | Item | Turkish search term | Notes |
|---|---|---|---|
| 1 | The vinyl sheet | `parke desenli PVC muşamba` (colour: `koyu kahve` or `ceviz desenli`) | 2.5 to 3 mm thick, **mat** (matte, never glossy), foam or felt backed, wear layer 0.3 mm or more. **3 m wide roll**, about 15 m² (see the roll width section below) |
| 2 | Double-sided tape | `çift taraflı halı bandı` | Holds the edges to the tile |
| 3 | Utility knife + spare blades | `maket bıçağı` | Blades go dull fast and a dull blade tears vinyl. Buy spares |
| 4 | Long metal ruler | `metal cetvel` | Cut along it for straight lines |
| 5 | Felt pads for furniture legs | `keçe ayak pedi` | Every leg. Use wide ones under heavy pieces (shelf unit, bed). Soft vinyl dents for good |
| 6 | Clear silicone (optional) | `şeffaf silikon` | One thin line along the bottom of the walls, especially by the sink, so crumbs and water cannot get under the edge |
| 7 | Alcohol or degreaser (only if the tile is greasy) | `yağ çözücü` | Tape will not stick to a dirty tile |
| 8 | Grout filler (only if needed) | `derz dolgusu` | Only if the grout lines are deeper than about 2 mm (see the checks) |

### Roll width: 3 m (decided after the tile measurement)

- Rolls usually come in **2, 3 and 4 m** widths.
- At the measured tile size (0.652 m) the room is about **2.71 m wide** and 3.0 m deep, with a hall about 1.57 m long and 1.14 m wide, so the whole floor is about 9.9 m². A **3 m roll covers the width in one piece with no seam**. Order about **15 m²** (3 m wide by about 5 m long: the main room plus the hall, plus trimming waste). The roll can run through the hall as well, trimmed to the narrower width.
- This is why the earlier idea of a 4 m roll (about 21 m², a 4 m long tube of 35 to 45 kg that might not fit in the stairwell) was dropped. A 3 m roll is cheaper and easier to carry.
- **Before ordering, tape-measure the real width.** The room is only about 2.71 m from a derived figure. If it turns out over 3 m, a 3 m roll leaves a gap along one wall that needs a filler strip and a seam (tape under it, silicone along it), and a 4 m roll becomes the answer again. Also check the roll's tube length against the stairwell or lift.
- Ask the seller whether the roll can come as two shorter pieces if it will not fit. That brings a seam back: tape under it and seal it with silicone.
- The Godot model shows no seam. Its room is 3.11 m wide at the old scale, so a 3 m roll would show an 11 cm filler strip there. To show it, set `seam_x` in `shaders/vinyl_wood.gdshader` to 3.0.

### How to lay it

1. Wash the tile and let it dry (degrease if it is greasy).
2. Unroll the sheet, cut it a bit too big, and leave it flat for a day or two so it relaxes. If you trim on day one it can buckle later.
3. Cut it to fit along the walls with the knife and the metal ruler. Leave about 3 to 5 mm at the walls (the skirting hides it).
4. Stick tape under the edges and press them down.
5. Run a thin line of silicone at the bottom of the skirting if you bought it.
6. Put felt pads on the furniture before it goes on the floor.

A 3 m roll of this length is a heavy tube (probably 25 to 35 kg). Get it delivered to the door, check it fits the stairwell or lift first, and ask someone to help carry it up. Run the planks toward the window.

### Checks before buying (do these while you can see the room)

- **Gap under the entrance door.** The vinyl adds about 3 mm. If the door has less than that, it will scrape.
- **Depth of the grout lines.** Drag a fingernail along one. If it drops deeper than about 2 mm, buy the grout filler (item 8), or the vinyl will slowly sink into the lines under furniture.
- **Gap between the skirting and the tile.** If it is wider than about 5 mm, silicone will not cover it. Use a self-adhesive flexible skirting strip (`kendinden yapışkanlı flex süpürgelik`) on top instead.
- **Is the skirting firmly fixed?** Press along it. Loose or missing pieces will show the vinyl edge.
- **Tape-measure the room width and depth** (and the hall). The tile measurement (0.652 m per tile) already shrank the room from 13 to about 9.9 m². Confirm it, because the roll width and the amount to order depend on it.

### Decisions already made

- **Skirting (süpürgelik):** leave the existing one. Do not buy new.
- **Door threshold strip (eşik):** skipped for now.
- **Rug:** leaning toward the round 120 cm ARTİSAN Concept TYANA polypropylene sisal-look rug (see the Godot section), not bought. Its position is a guess (a small rug, worst case revisited). The only stated preference is that **upkeep is priority number one**: wash it rarely and make sure a stain cannot ruin it. `rug_spec_tags.txt` in the repo root is the shop-filter checklist purged down to only the tags that affect that. It must also not be rubber-backed or latex-backed, because that stains vinyl yellow or brown. Use a felt backing or a pad that says it is safe for vinyl (PVC-safe).
- **Chair:** a desk chair with hard wheels scratches vinyl. Use soft wheels or a chair mat.
- **Cleaning:** a damp mop with mild soap, and a vacuum on its hard-floor setting. No steam mop and no abrasive pads, because steam loosens the tape and lifts the edges.
- **Darker floors show dust and crumbs more.** This is the price of the dark colour.

## Next steps: the dream room

The foundation (shell, materials, lights, view, walkable Godot version) is done. From here the work is the new design.

1. Tape-measure the real room (width, depth, hall), ceiling height and window size. The tile is measured (0.652 m), so the model is about 13% too big in plan; rebuilding it at the right size is optional and postponed. Also measure the gap under the entrance door: the vinyl adds about 3 mm.
2. Decide the layout: bed, open shelf divider, desk at the window, one seat, rug. Keep a 60 to 70 cm walking path.
3. Build or source the furniture in the honey wood, cream and green palette. Prefer real modelled assets (Poly Haven, Sketchfab, Poly Pizza) over hand-built boxes, because boxes read as "Blender boxes". Assets that come through glTF need a matching shader entry in `main.gd` if they use procedural materials.
4. Materials: honey wood, linen, wool, jute, rattan, ceramic, with sage and terracotta accents. Give them real surface response (roughness variation, sheen), not flat colour.
5. Lighting: keep the Godot dreamy-afternoon look, and add a warm-lamp evening state (many low sources, no single bright ceiling light). Re-bake the GI after every layout change.
6. Plants at three levels, and decor last.
7. Optional: richer street and skyline outside, and a Blender daylight scene to match the Godot look.

## Walkable version in Godot (`room-godot/`)

Godot 4.7.2 project that lets me walk around the room in first person. Open it with `Godot_v4.7.2-stable_win64.exe --path room-godot --editor`, or run `main.tscn` (it is the main scene).

- **Controls:** WASD walk, Shift sprint, mouse look, Esc frees the mouse (click to recapture, it does not leave full screen), **L** toggles the electric downlights (off by default). The game starts **full screen** (`window/size/mode=3` in `project.godot`); leave it with Alt+F4 or by stopping it from the editor.
- **Files:** `main.tscn` (scene), `main.gd` (collision, material shaders, sun, light toggle), `player.gd` (walker), `assets/room.glb` (the exported room), `floor_tiles.gdshader` and `shaders/` (`satin` generic real-object surface with smudged roughness, clearcoat, brushed metal and fabric sheen, `vignette`, `plaster` roughcast with bump, `door` striped gloss black, `counter_top` speckled, `facade` windows on the buildings, `vinyl_wood` the floor, `rug` the rug). `main.gd` swaps the flat glTF colours for these shaders by material name.
- **Floor:** `shaders/vinyl_wood.gdshader` models the planned rolled oak-print vinyl: 16 cm planks running toward the window (Z), staggered 1.22 m lengths, printed joints as shallow grooves, per-plank tone and grain, a print that repeats every 7 rows by 5 planks, matte roughness of about 0.6, and an optional hairline butt seam (`seam_x`, currently moved out of the room so there is none; 3.0 shows a 3 m roll on the model's 3.11 m width, with an 11 cm filler strip whose print is slightly out of register). The wood colours are `wood_light` and `wood_dark` at the top of the shader (dark reddish-brown walnut). Detail layers fade with pixel footprint per axis, so nothing shimmers. `floor_tiles.gdshader` (the old tile) is no longer used but kept for comparison: point `_shared["Floor"]` in `main.gd` back at it to see the old floor. The 3 mm thickness of the real vinyl is not modelled.
- **Rug:** `main.gd` builds a round 1.2 m, 8 mm thick rug (`_build_rug`) from `assets/rug_round.png`, a square crop of the product photo `new-rug.png` (repo root, background already transparent), cut 4 px inside the rug's edge to drop the halo, with the transparent corners filled with the rug's average colour so they cannot darken the edge in the mipmaps. It models the Trendyol listing ARTİSAN Concept TYANA "Sisal Dokuma Halı, Doğal Jüt Renkli, Yıkanabilir, Yuvarlak" (polypropylene, machine-made, woven backing, pile under 6 mm, beige), which passes every upkeep filter in `rug_spec_tags.txt`. Its reviews are for 160 cm; 120 cm was chosen, so check that size exists. `shaders/rug.gdshader` maps the photo from world position, adds a soft fabric sheen, a fibre bump from the photo's brightness, and concentric ridges every 7 mm (`RUG_RING_PITCH`, faded with distance so they do not shimmer), and gives the sides a darker tan edge. The position is a guess (`RUG_CENTER` at the top of `main.gd`): in the open floor in front of the counter. The photo is loaded as a raw image at runtime (so it gets mipmaps and needs no editor import), which Godot warns "will not work on export"; that only matters if the game is ever exported. The rug has no collision and casts no shadow. The scene loads it without shader errors (seen when the GI was baked), but **nobody has looked at it yet**, so its position, size and the ridge detail are untested. The earlier striped rectangle (Decomia Home vintage kilim, a look-only placeholder that likely failed the filters) is kept as `rug-model.webp` and `assets/rug.png`, unused.
- **GI and the floor colour:** the GI bake reads the flat glTF colour, not the shader. `tools/export_to_godot.py` sets `Floor` to the average vinyl colour (`#823f26`), so change it there if the wood tone changes, re-export, then re-bake. The bake and the export were both redone on 2026-09-26 with the final dark floor, the rug and the corrected wall, ceiling and soffit colours (see the export script gotcha below).
- **Export script gotcha:** never put a comment at the end of a line inside the `M` colour table in `tools/export_to_godot.py`. A `#` comment there swallowed the `Wall`, `Ceiling` and `Soffit` entries on the same line, the export silently gave them the wrong flat colours, and the GI bake used them. Put comments on their own line.
- **Godot re-import before baking:** after re-exporting `room.glb`, run `Godot_v4.7.2-stable_win64_console.exe --path room-godot --headless --import` so Godot picks up the new file, then run the bake.
- **MCP autoloads:** the Godot MCP plugin adds three autoload lines to `project.godot` and the editor removes them when it closes or the plugin stops (a `--headless --import` run prints "Plugin stopped"). Check `git diff room-godot/project.godot` before committing and do not commit the removal; restore the `[autoload]` block.
- **Room detail:** `tools/add_room_detail.py` adds skirting, window frame with mullion, radiator, brown curtain, door handle, sockets, switch, smoke detector, counter details (fridge and cabinet doors, handles, edge strip, sink, tap, legs) and street life (trees, lamps, cars). Everything it creates is named `D_*` and it rewrites them on each run. It saves `room.blend`.
- **Look:** a warm, soft "dreamy afternoon" without being a sunset: a late-afternoon sun about 33 degrees up with a strongly softened penumbra (sun energy 1.7, angular size 3.5 degrees, shadow blur 2.5, one 12 m shadow cascade, ambient 0.6, flat contrast; it was softened because it looked "way too sharp"; raising the angular size to 5+ softens it more at the cost of noisier shadows, and raising the energy to about 1.85 brings back punch), cool skylight fill spots outside the window, thin volumetric haze (sunbeams), gentle bloom, light depth of field on the far street, filmic tonemapping, and a soft vignette. Dust motes drift in the sunbeam.
- **Lighting details:** baked VoxelGI for bounce light plus a ReflectionProbe so glossy surfaces reflect the room, not only the sky. The GI file `room-godot/lighting/voxel_gi.res` is git-ignored (17 MB). After changing lights or geometry, regenerate it with `Godot_v4.7.2-stable_win64_console.exe --path room-godot -s res://tools/bake_gi.gd` (opens a window for a few seconds). Glass and blinds must not cast shadows. SDFGI was tried and dropped (interior went black).
- **Getting the room out of Blender:** `tools/export_to_godot.py` replaces the procedural materials with flat colours matching the photos, then exports the room and the exterior as glTF. Run it headless: `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" -b room.blend --python tools/export_to_godot.py`. It does not save `room.blend`. Re-run it after every Blender change, then let Godot re-import.
- **What the export loses, and how it is rebuilt:** Blender's procedural materials do not survive glTF, so `tools/export_to_godot.py` flattens them to plain colours and the Godot shaders above recreate the wall, ceiling, door, worktop, facade and floor looks from world position. Any new Blender material needs either a plain Principled colour (exported as is) or a matching shader entry in `main.gd`.
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
- In Godot work, check every visual change with a game screenshot (`get_game_screenshot` saves a PNG to `%APPDATA%\Godot\app_userdata\room-godot\mcp_screenshot_res.png`, which is easier to read than the base64 reply). Wait 10 to 20 seconds after `play_scene` before judging, because shaders, fog and the reflection probe take a moment to settle.
- After any change to lights or room geometry, re-bake the GI (see the Godot section). The bake data is git-ignored.
- The user cares most about surface materials and lighting. Prefer effort there over more geometry. Keep the mood subtle, not extreme.
- The user sometimes says not to run tests or visual checks (a few turns in a row). Respect it, and say plainly what is unverified. A headless run of the GI bake still shows shader compile errors, which is a cheap non-visual check.
- On floor and rug purchases: upkeep (waterproof, no crumb traps, wash rarely, stains must not ruin it) is priority number one, and the user wants short, simple explanations and a checklist rather than expert jargon (they have never done a job like this).
- Rug choices are judged against the filters in `rug_spec_tags.txt`. A product photo for the Godot model is a look reference, not a purchase decision.
