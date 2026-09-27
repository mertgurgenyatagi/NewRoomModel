# NewRoomModel

A 3D model of my studio apartment (built as ~13 m², but the real floor tile turned out smaller, so the real room is about 9.9 m², see Scale), built in Blender 5.2 and driven by Claude Code through the [blender-mcp](https://github.com/ahujasid/blender-mcp) server, plus a Godot 4.7 project that lets me walk around it in first person. The goal is to design the room's future look (all current furniture removed, only the mini kitchen stays) before changing anything in real life.

## Status at a glance

| Area | State |
|---|---|
| Style direction | Done, see [STYLE_ANALYSIS.md](STYLE_ANALYSIS.md) |
| Room dimensions | Built at **0.75 m per floor tile**, from the tile-unit plan in [room_plan.png](room_plan.png). The tile was then measured at **0.652 m**, so the model is about 13% too big in plan. **Deliberately kept as it is for now** (decision 2026-09-26). Ceiling height and window size are still unmeasured |
| Blender shell (walls, window, counter, door) | Done, saved in [room.blend](room.blend), with photo details added (skirting, window frame, radiator, curtain, door handle, sockets, counter details, street trees, lamps and cars) |
| Materials | Done for the existing room, matched to the photos in `actual_room/` |
| Lighting | Blender: early-sunset sun with the electric lights off (the lights are in a hidden collection). Godot: **three modes on keys 1, 2 and 3**: day (a natural, dreamy late-afternoon look), an early golden **sunset**, and **night** (dark outside, only the ceiling downlights), each with its own baked bounce light. Sunset and night have never been looked at, see "Lighting modes" in the Godot section |
| Exterior | Done: simple urban street outside the window |
| Walkable Godot version | Done: first-person walk-through in `room-godot/` with collision, custom surface shaders, baked GI, haze, bloom and vignette. See the Godot section below |
| Floor (the real plan) | **Done, the book is closed.** Rolled dark-walnut wood-print vinyl sheet (muşamba) laid loose over the tile, now a 3 m wide roll of about 15 m². Modelled in Godot only. `room.blend` still has the old tile material. Nothing is bought yet. See "Real-life floor plan" |
| Rug | Leaning toward a round 120 cm polypropylene sisal-look rug (ARTİSAN Concept TYANA), placed as a guess in Godot. I looked at it and the floor in Godot and they look good. Not bought. It now sits almost against the daybed and needs moving. The upkeep filters are in `rug_spec_tags.txt` |
| Seating hero (daybed) | **Done for now (merged from `seating-hero`).** Modelled in Blender and Godot, day position: the real frame, the mattress, the beige kilim (now draped all the way down to the legs), two arm-rest boxes covered in a beige fabric slipcover, two beige back cushions and three sage scatter pillows. See "Seating hero" below |
| Other furniture, decor, the new look | **Not started. This is the next phase ("the dream room")** |

## Repository contents

| Path | What it is |
|---|---|
| `PROJECT.md` | This file |
| `SHOPPING_LIST.md` | Everything decided but not bought yet, with Turkish search terms. No links. Price is no longer tracked closely (there will be a cost-cutting pass at the very end) |
| `room.blend` | The Blender model. `room.blend1` is Blender's automatic backup and is git-ignored |
| `room-godot/` | The Godot 4.7 project: the walkable room, shaders, lighting and the Godot MCP addon |
| `tools/` | Blender scripts: `add_room_detail.py` (adds detail to `room.blend`), `add_daybed.py` (adds the daybed, `S_*` objects) and `export_to_godot.py` (exports to glTF for Godot) |
| `STYLE_ANALYSIS.md` | Style analysis of the 12 mood-board images: palette, materials, light, layout moves, design rules |
| `ROOM_DIMENSIONS.md` | Old photo-derived dimension estimate. Superseded by the plan and the scale below |
| `room_plan.png` | My hand-drawn plan, labelled in floor-tile units. Window side at the top |
| `kilim-texture.png` | Photo of the chosen beige kilim's weave, used as its texture in Godot. Identical copy: `room-godot/assets/kilim.png` |
| `new-rug.png` | Product photo of the round rug now in the Godot model (background already transparent). Cropped copy: `room-godot/assets/rug_round.png` |
| `rug-model.webp` | Top-down photo of the earlier striped rug, no longer used. Cropped copy: `room-godot/assets/rug.png` |
| `rug_spec_tags.txt` | Shop-filter checklist for choosing a rug, purged down to the tags that affect low maintenance |
| `rugs.txt` | Two saved Trendyol filter searches (one for "halı", one for "kilim") with the upkeep filters already applied |
| `style_refs/` | 12 mood-board images (Pinterest exports), two of which are identical |
| `actual_room/` | 7 photos of the current room, used for materials, lights and layout |
| `wallpaper_textures/` | Candidate wallpaper photos (`a.jpg`/`.jfif`, `b`, `c`), tried on the wall behind the daybed in Godot. None chosen yet |

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

**Measured (2026-09-26): 2.7 tiles = 1.76 m, so one tile is 0.652 m, not 0.75 m.** The plan units are therefore about 13% smaller, and the model (still built at 0.75 m) is too big: the room is really about 2.71 m wide and 3.0 m deep (hall 1.57 m long), about 9.9 m² in total, and the counter about 1.24 x 0.72 m. Heights (ceiling, door, counter height) are not affected by the tile. **Decision (2026-09-26): keep the model at 0.75 m for now, do not rescale.** Everything in this file that quotes metres for the room (the plan table, the Blender section, the Godot rug and planks) is at the old 0.75 m scale. The exception is the daybed, which is modelled at its real size (a 90 x 190 cm mattress), so it looks about 13% small in the too-big room. Doing it properly would mean rebuilding the walls and floor at the new plan size and repositioning the details (door, window, radiator and skirting keep their real sizes, so it is not a uniform scale), then re-exporting and re-baking the GI. Take real measurements with a tape before buying anything sized to the room.

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
| `Room` | The shell, the counter, the window blinds, the sun, the cameras, and the daybed (`S_*` objects, added by `tools/add_daybed.py`) |
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
- The current furniture is not modelled, on purpose. The old bed and its headboard are gone from the model; only the new daybed is in it.
- Small dotted specks on the top of the back cushions and on the box lids: shadow-map artefacts on upward faces, not fabric. Not fixed.
- The ceiling's flat colour, used for the GI bake, is still the old grey `#c7c3bd` in `tools/export_to_godot.py`'s colour table. The visible ceiling colour was changed to `#aa6a1c` (2026-09-27) only in `main.gd`'s shader, so a fresh GI bake would still tint bounce light with the old grey until the export script's table is updated too.
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

20. Seating hero, first steps (2026-09-26): a new branch `seating-hero`, and the first piece of the dream room is a daybed. It was worked out in real life first, through five short free-text questionnaires (each round's questions came only from the previous answers), a five-option slideshow, and a long shopping conversation. Placement (left wall, main room) and use (bed at night, sofa by day) were fixed early. Everything else was treated as a soft hint.
21. The seat is already about 57 cm off the floor (a 40 cm frame plus a 17 cm mattress), a bit high for someone 1.76 m tall (a seat of 42 to 47 cm is comfortable), so a foam pad, which adds height, was rejected. The mattress is too soft to sit on, so the chosen fix was a thin, stiff, flat-woven kilim over the whole mattress: Alpina Home "Stella Jüt Hasır" (polypropylene, woven backing, machine-made, thin pile, no fringe), in beige. Beige over sage or terracotta, because the cushions can carry the accent colours and beige lifts the dark floor. A 3 cm, 32-density foam pad was the backup. Not bought.
22. The model's first frame was a wooden one on long legs. The real frame (photos in `actual_room/`) is a white board along each side with short black metal legs, so it was rebuilt that way.
23. Arm rests, because the bed has nothing for the pillow to lean on and its ends show. A hollow wooden crate with a cushioned cap was built, then removed. Then two identical oak boxes were built from a proposal (30 x 90 x 70 cm, box-joint corners, lift-off lid with a finger notch, no handle). They look out of place texturally, and I decided to **keep them as they are for now** and see how the rest of the room shapes up. Directions discussed for later, based on `style_refs/`: the box painted matte sage with a raw-wood lid (my pick, like the sage shelf unit in new_refs 3), woven cane sides, raw rustic pine planks, or fabric-wrapped. A carpenter will probably build the real ones, and the plan is to strap them to the legs of the bed frame.
24. Godot lighting modes (2026-09-27): a golden early **sunset** and a **night** were added next to the day look, on keys 1 to 3, each with its own baked bounce light. I asked for "non aggressive, early sunset, not totally red" and "dark outside with only the artificial ceiling lights inside". These were tuned by numbers, never by eye, because of the rule below.
25. Standing rule (2026-09-27): **never launch a live Godot game instance** (no `play_scene`, no running the main scene, no opening the editor to play it, so no game screenshots) unless I ask for it. Headless runs are fine: `--headless --import` and script parse checks. The GI bake opens a Godot window for a few seconds; it has not been decided whether that counts, so ask before running it again.
26. Back support (2026-09-27): a real, deep back, not leaning cushions. It works because the back is not fixed: **the back cushions come off at night**. Before sleeping you pull the bed away from the wall by about 40 cm and drop the cushions in the gap behind it; by day you lift them onto the mattress and push the bed against the wall. That gives a 90 cm mattress at night and a 50 cm seat by day. The depth started at 45 cm and was cut to 40 (seat 50). Only the day position is modelled. Things this needs in real life: glide pads so the bed slides on the vinyl, and the arm boxes strapped to the frame so they move with it. The cushions are two long **firm foam blocks** (about 94 x 40 x 50 cm each, D30 medium-firm: firm like a sofa back, "maybe even slightly less so"), each in a removable zippered **beige linen cover**; the pillows are three **sage** scatter pillows. Three 62 cm blocks were tried first and looked like ottomans, so it is two. A first sage version looked like slime (minty colour, wobbly noise, pixelated weave) and was redone. Turkish search terms: "ölçüye göre sünger", "blok sünger", "D30 sünger", "orta sert sünger", "fermuarlı sünger kılıfı", "ölçüye göre kılıf dikimi", "döşemelik kumaş", or a local "sünger atölyesi". Not bought.
27. Kilim coverage extended (2026-09-27): the kilim's front drape now runs all the way down to the top of the frame's legs (39 cm drop), not just to the mattress edge (17 cm), so the white frame board never shows. This needs about 129 cm of kilim width (90 cm top + 39 cm drop); the 110 cm kilim from decision 21 falls 19 cm short. **Not resolved**, see decision 3 below and `SHOPPING_LIST.md`.
28. Arm-rest finish chosen (2026-09-27): a **fitted beige bouclé slipcover**, out of four directions considered (fabric wrap, a wrapped-and-strapped throw, a padded body with a separate cushion lid, or this one). Picked because it's the most finished-looking and, unlike a glued/stapled upholstery job, still removable and washable, matching the upkeep-first approach used for the rug and kilim. Modelled: the box-joint corners are gone (they would never show under a cover) in favour of plain rounded corners and walls, the lid is more generously rounded (cushioned, not wooden), and a raised band at the lid line stands for the slipcover's zip seam. Only the recessed plinth stays bare oak, like feet peeking out under a loose cover. Turkish terms: "ölçüye özel kılıf dikimi", "sandık kılıfı" / "kutu kılıfı", "fermuarlı kılıf" or "cırt bantlı kılıf", fabric "boucle kumaş" or "kalın keten kumaş" in bej, plus "ince sünger vatka" for the padding underneath. See `SHOPPING_LIST.md`.
29. Wallpaper (2026-09-27, undecided): three candidate patterns (`wallpaper_textures/a`, `b`, `c`) can be tried on **only the wall behind the daybed** (`Wall_Left`) with key **0** in Godot, top to bottom, no dado strip. Every other wall turns a plain flat beige (`#ded2b8`, no grain, no roughness variation) at the same time, so the accent wall reads as the one papered wall; "none" puts every wall back to the ordinary grey plaster. Nothing is chosen, and it is not in the shopping list for that reason.
30. Ceiling colour (2026-09-27): changed to `#aa6a1c`, a burnt orange/amber, in the Godot shader only. See Known issues for the GI-bake mismatch this leaves.
31. GPU cost review (2026-09-27): the room got noticeably heavy to run, so a report was given (component by component, star-rated) and cuts were made where the visual loss is small. Applied: the **reflection probe** no longer updates every frame (it bakes once, then re-bakes for one frame only when the lighting mode or the wallpaper changes, via `_refresh_reflection_probe()` in `main.gd`); **volumetric fog is off** (the sunbeam shafts are gone, regular fog stays); the sun's **shadow map** dropped from 8192 to 2048 and **soft shadow quality** from Ultra to Medium; **SSIL is off**; the three sky-fill spotlights **no longer cast shadows** (their light stays); **MSAA dropped from 4x to 2x** with FXAA added. Left alone: SSAO, glow, depth of field, VoxelGI, the dust motes, and the custom surface shaders, since most of their cost was really the reflection probe forcing them to run six extra times a frame.

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

## Seating hero (daybed)

Built on branch `seating-hero`, merged. The first piece of the dream room is a bed that works as the sofa during the day. It was worked out in real life first, then modelled. There is no separate file for it any more; everything that matters is in this section and in decisions 20 to 23 and 26 to 28.

**Decided:**

1. **Placement (2026-09-26):** against the left wall in the main room, long side to the wall.
2. **Use (2026-09-26):** a daybed: a bed at night, the sofa during the day. The change from bed to sofa should be a quick "snap" (about 15 seconds), or it will stay a bed.
3. **The firming layer (2026-09-26):** a flat-woven kilim over the mattress, no foam. Alpina Home "Stella Jüt Hasır", beige, 110 x 190 cm, about 1,390 TL on Trendyol. Not bought. See decision 21. **Superseded by decision 27:** the front drape now runs all the way to the legs, which needs about 129 cm of width, not the 107 cm first planned — the 110 cm kilim is 19 cm short. Not resolved; see `SHOPPING_LIST.md`.
4. **The frame (2026-09-26):** the existing one stays, without its headboard, which is going. It is a white board along each side on short black metal legs, 40 cm from the floor to the mattress.

**Real measurements:** mattress 90 x 190 cm, 17 cm thick. The seat is about 57 cm off the floor (about 53 once it sinks). By day the 90 cm width splits into a 50 cm seat and a 40 cm back support (decision 26).

**Not decided (do not assume any of these):** the kilim size conflict (decision 27), whether the kilim stays on at night, the exact fabrics and pillow sizes (the model uses stand-ins), whether the rocking chair fits, and what else goes in the room.

**Arm rests:** two identical boxes stand at the ends, outside the mattress: 30 cm deep along the wall, 90 cm wide, 70 cm tall (13 cm above the seat), hollow, on a recessed plinth, with a lift-off lid with a half-round finger notch and no handle. **The look is decided (decision 28):** a fitted beige bouclé slipcover over the body and lid, with a bare-oak plinth peeking out at the floor. The box itself will probably be built by a carpenter, strapped to the legs of the bed frame, with the slipcover made separately. In the model, the far box covers the wall socket at the window end (Y = 4.5 m); check where the real sockets are.

**In the model:** `tools/add_daybed.py` builds everything, as objects named `S_*` in the `Room` collection, at real size, against the left wall in the middle of the main room. It is safe to re-run: it deletes the old `S_*` objects first. The constants at the top move or resize the bed and the boxes.
- **Frame:** four white boards (`S_Bed_Board_*`, about 22 cm tall, read off the photos and not measured), a thin deck and four black metal legs. The legs reuse the dark `Frame` material.
- **Mattress:** rounded, colour a placeholder.
- **Kilim:** a top plate and a front plate, flat colour `#c3b1a6` (the photo's average, because the GI bake reads it). The front plate now drops all the way to the top of the legs (decision 27), not just to the mattress edge. In Godot it uses the real product photo, `kilim-texture.png` (repo root, copy in `room-godot/assets/kilim.png`), mapped once over the whole cloth (top and front face together) by `shaders/kilim.gdshader`. `_build_kilim()` in `main.gd` measures the `S_Kilim_*` meshes, so the texture follows the bed if it moves. Like the rug it is loaded as a raw image, so Godot warns it "will not work on export".
- **Arm boxes:** `S_ArmBox0_*` and `S_ArmBox1_*`. Bare oak plinth and hidden floor plate (material `ArmBoxOak`, `#c8975f`); everything else — four walls, plain corner columns, a seam band at the lid line, and a generously rounded lid — is the fabric slipcover (material `ArmBoxFabric`, `#c9bda0`, decision 28). The box-joint corners from the first version are gone, since they would never show under a cover. The lid's finger notch (a boolean cut) stays, as the slipcover's pull tab. The hidden strap slot is not modelled.
- **Back cushions:** `S_Back0_*` and `S_Back1_*`. Each is a rounded, dense-mesh body (fabric puffed on the faces, faint pull-wrinkles near the corners) plus a welt (piping cord) round its top and bottom seams. 94 x 40 x 50 cm, sitting on the kilim against the wall, beige `#c0b198` (material `CushionBeige`). Constants `BACK_D`, `BACK_H`, `N_BACK` at the top of the back-support section of `add_daybed.py`.
- **Scatter pillows:** `S_Pillow0` to `S_Pillow2`, sage `#78876c` (`CushionSage`): lens-shaped square pillows with a seam and pinched corners, one leaning on each arm box and one on the backs. Their sizes, tilt and spots are the `pillow(...)` calls at the end of the script. Positions are pushed against the surface they lean on.
- **Godot looks:** `_shared["Mattress"]`, `["BedFrameWhite"]` and `["ArmBoxOak"]` in `main.gd` (on the `satin` shader), and `["CushionBeige"]`, `["CushionSage"]` and `["ArmBoxFabric"]` on `shaders/fabric.gdshader`: woven cloth from colour slubs and a faint weave that fades with distance (noise bumps had turned into big pixels). `ArmBoxFabric` is tuned nubbier (bouclé) than the linen cushions: more slub, less sheen.
- **To rebuild:** run the script, then `export_to_godot.py`, then re-import and re-bake the GI (see the Godot section). The last run gave 45 `S_*` objects (down from 99, since the box-joint fingers are gone) and 218 exported meshes. The GI bake is stale for everything from 2026-09-27 onward (the fabric-covered arm boxes, the extended kilim, the ceiling colour); the bake files are git-ignored, so re-bake on a fresh checkout anyway.

**Not yet done:** the night position of the bed (pulled out, cushions behind it, is not modelled) and moving the rug off the bed.

**How we worked:** rounds of a 3-question questionnaire, each a plain artifact page with free-text answers. Each round's questions came only from the previous answers, and I decided where the rounds led. It may be used again for the next pieces.

## Next steps: the dream room

The foundation (shell, materials, lights, view, walkable Godot version) is done. From here the work is the new design.

1. Tape-measure the real room (width, depth, hall), ceiling height and window size. The tile is measured (0.652 m), so the model is about 13% too big in plan; rebuilding it at the right size is optional and postponed. Also measure the gap under the entrance door: the vinyl adds about 3 mm.
2. Decide the layout: the daybed is placed (left wall). Still open: the open shelf divider, desk at the window, one seat (a rocking chair was mentioned), whether a wallpaper gets chosen for the wall behind the daybed, and where the rug goes now that the bed is there. Keep a 60 to 70 cm walking path.
3. Build or source the furniture in the honey wood, cream and green palette. Prefer real modelled assets (Poly Haven, Sketchfab, Poly Pizza) over hand-built boxes, because boxes read as "Blender boxes". Assets that come through glTF need a matching shader entry in `main.gd` if they use procedural materials.
4. Materials: honey wood, linen, wool, jute, rattan, ceramic, with sage and terracotta accents. Give them real surface response (roughness variation, sheen), not flat colour.
5. Lighting: the Godot day, sunset and night modes exist (see "Lighting modes"), but sunset and night are untuned. The night mode uses only the ceiling downlights, as asked. A warm-lamp evening state with many low sources (no single bright ceiling light) is still open. Re-bake the GI after every layout change.
6. Plants at three levels, and decor last.
7. Optional: richer street and skyline outside, and a Blender daylight scene to match the Godot look.

## Walkable version in Godot (`room-godot/`)

Godot 4.7.2 project that lets me walk around the room in first person. Open it with `Godot_v4.7.2-stable_win64.exe --path room-godot --editor`, or run `main.tscn` (it is the main scene).

- **Controls:** WASD walk, Shift sprint, mouse look, Esc frees the mouse (click to recapture, it does not leave full screen), **L** toggles the electric downlights (off by default), **1 / 2 / 3** switch the lighting mode to day, sunset or night (the mode name shows in the top-left corner for a moment). Switching sets the downlights too: off for day and sunset, on for night. The game starts **full screen** (`window/size/mode=3` in `project.godot`); leave it with Alt+F4 or by stopping it from the editor.
- **Files:** `main.tscn` (scene), `main.gd` (collision, material shaders, sun, light toggle, the rug, kilim and wallpaper builders, the mode keys), `lighting_modes.gd` (the day, sunset and night modes), `player.gd` (walker), `assets/room.glb` (the exported room), `floor_tiles.gdshader` and `shaders/` (`satin` generic real-object surface with smudged roughness, clearcoat, brushed metal and fabric sheen, `vignette`, `plaster` roughcast with bump, `door` striped gloss black, `counter_top` speckled, `facade` windows on the buildings (some glow at night), `vinyl_wood` the floor, `rug` the rug, `kilim` the daybed's kilim, `fabric` woven cloth for the cushions, pillows and the arm boxes' slipcover, `wallpaper` the accent-wall pattern). `main.gd` swaps the flat glTF colours for these shaders by material name.
- **Wallpaper (key 0, decision 29):** cycles **none → a → b → c → none**. Only `Wall_Left` (behind the daybed) gets the pattern, top to bottom, no dado strip; every other wall switches to a plain flat beige (`#ded2b8`, a `StandardMaterial3D` with `roughness = 1.0`, not a shader) at the same time, so the accent wall reads as the one papered one. "None" restores the ordinary grey plaster everywhere. The three source images are seamless tiles cut from `wallpaper_textures/` by `tools/make_wallpaper_tiles.py` (only needed for the first, non-seamless set; the current set already tiled cleanly and was copied straight in). Sizes are guesses (`WALLPAPERS` in `main.gd`). Nothing is chosen yet, so it is not in `SHOPPING_LIST.md`.
- **Rendering performance (decision 31):** the reflection probe bakes once instead of every frame, refreshing for one frame only when the lighting mode or the wallpaper changes (`_refresh_reflection_probe()`); volumetric fog is off; the sun's shadow map is 2048 (was 8192) with Medium soft-shadow quality (was Ultra); SSIL is off; the three sky-fill spotlights (`SkyFill/Fill*`) no longer cast shadows; MSAA is 2x with FXAA added (was 4x, no FXAA).
- **Floor:** `shaders/vinyl_wood.gdshader` models the planned rolled oak-print vinyl: 16 cm planks running toward the window (Z), staggered 1.22 m lengths, printed joints as shallow grooves, per-plank tone and grain, a print that repeats every 7 rows by 5 planks, matte roughness of about 0.6, and an optional hairline butt seam (`seam_x`, currently moved out of the room so there is none; 3.0 shows a 3 m roll on the model's 3.11 m width, with an 11 cm filler strip whose print is slightly out of register). The wood colours are `wood_light` and `wood_dark` at the top of the shader (dark reddish-brown walnut). Detail layers fade with pixel footprint per axis, so nothing shimmers. `floor_tiles.gdshader` (the old tile) is no longer used but kept for comparison: point `_shared["Floor"]` in `main.gd` back at it to see the old floor. The 3 mm thickness of the real vinyl is not modelled.
- **Rug:** `main.gd` builds a round 1.2 m, 8 mm thick rug (`_build_rug`) from `assets/rug_round.png`, a square crop of the product photo `new-rug.png` (repo root, background already transparent), cut 4 px inside the rug's edge to drop the halo, with the transparent corners filled with the rug's average colour so they cannot darken the edge in the mipmaps. It models the Trendyol listing ARTİSAN Concept TYANA "Sisal Dokuma Halı, Doğal Jüt Renkli, Yıkanabilir, Yuvarlak" (polypropylene, machine-made, woven backing, pile under 6 mm, beige), which passes every upkeep filter in `rug_spec_tags.txt`. Its reviews are for 160 cm; 120 cm was chosen, so check that size exists. `shaders/rug.gdshader` maps the photo from world position, adds a soft fabric sheen, a fibre bump from the photo's brightness, and concentric ridges every 7 mm (`RUG_RING_PITCH`, faded with distance so they do not shimmer), and gives the sides a darker tan edge. The position is a guess (`RUG_CENTER` at the top of `main.gd`): in the open floor in front of the counter. The photo is loaded as a raw image at runtime (so it gets mipmaps and needs no editor import), which Godot warns "will not work on export"; that only matters if the game is ever exported. The rug has no collision and casts no shadow. The scene loads it without shader errors (seen when the GI was baked), and I looked at it in the game and it looks good. Its position is still a guess, and it now sits almost against the daybed's front. The earlier striped rectangle (Decomia Home vintage kilim, a look-only placeholder that likely failed the filters) is kept as `rug-model.webp` and `assets/rug.png`, unused.
- **GI and the floor colour:** the GI bake reads the flat glTF colour, not the shader. `tools/export_to_godot.py` sets `Floor` to the average vinyl colour (`#823f26`), so change it there if the wood tone changes, re-export, then re-bake. The bake and the export were both redone on 2026-09-26 with the final dark floor, the rug and the corrected wall, ceiling and soffit colours (see the export script gotcha below).
- **Export script gotcha:** never put a comment at the end of a line inside the `M` colour table in `tools/export_to_godot.py`. A `#` comment there swallowed the `Wall`, `Ceiling` and `Soffit` entries on the same line, the export silently gave them the wrong flat colours, and the GI bake used them. Put comments on their own line.
- **Godot re-import before baking:** after re-exporting `room.glb`, run `Godot_v4.7.2-stable_win64_console.exe --path room-godot --headless --import` so Godot picks up the new file, then run the bake.
- **MCP autoloads:** the Godot MCP plugin adds three autoload lines to `project.godot` and the editor removes them when it closes or the plugin stops (a `--headless --import` run prints "Plugin stopped"). Check `git diff room-godot/project.godot` before committing and do not commit the removal; restore the `[autoload]` block.
- **Room detail:** `tools/add_room_detail.py` adds skirting, window frame with mullion, radiator, brown curtain, door handle, sockets, switch, smoke detector, counter details (fridge and cabinet doors, handles, edge strip, sink, tap, legs) and street life (trees, lamps, cars). Everything it creates is named `D_*` and it rewrites them on each run. It saves `room.blend`.
- **Look (the day mode, key 1):** a warm, soft "dreamy afternoon" without being a sunset: a late-afternoon sun about 33 degrees up with a strongly softened penumbra (sun energy 1.7, angular size 3.5 degrees, shadow blur 2.5, one 12 m shadow cascade, ambient 0.6, flat contrast; it was softened because it looked "way too sharp"; raising the angular size to 5+ softens it more at the cost of noisier shadows, and raising the energy to about 1.85 brings back punch), cool skylight fill spots outside the window, thin volumetric haze (sunbeams), gentle bloom, light depth of field on the far street, filmic tonemapping, and a soft vignette. Dust motes drift in the sunbeam.
- **Lighting details:** baked VoxelGI for bounce light plus a ReflectionProbe so glossy surfaces reflect the room, not only the sky. There is one GI file per lighting mode in `room-godot/lighting/`: `voxel_gi.res` (day), `voxel_gi_sunset.res` and `voxel_gi_night.res`. All are git-ignored (about 19 MB each). After changing lights or geometry, regenerate them with `Godot_v4.7.2-stable_win64_console.exe --path room-godot -s res://tools/bake_gi.gd`, which bakes all three, each with its own sun, sky and lights, and opens a window for a few seconds each (**ask first**, see decision 25). To bake only some, add them after `--`, for example `-s res://tools/bake_gi.gd -- night`. Glass and blinds must not cast shadows. SDFGI was tried and dropped (interior went black).
- **Lighting modes (keys 1, 2, 3):** `lighting_modes.gd` captures the authored day look from the scene when the game starts, and the other modes are overrides on top of it. Switching also swaps in that mode's baked GI. **The sunset and night values are estimates that were never looked at**, so expect to tune them.
  - **Sunset (2):** the sun drops to about 13 degrees (`from` (3, 4.6, -20)), golden `(1.0, 0.76, 0.48)` and not red, energy 1.9, with more haze energy (2.4) so the beams glow. The sky goes from soft blue `(0.35, 0.5, 0.78)` at the top to a peach horizon `(0.98, 0.74, 0.55)`. The haze is warm and a bit thicker, ambient 0.55, saturation 1.1, the cool sky-fill spots dimmed to 0.6 and tinted slightly pink. The downlights stay off.
  - **Night (3):** a dark navy sky, no sun and no sky-fill spots, ambient 0.35, stronger bloom (glow 0.9, threshold 0.9), and only the three ceiling downlights on. About a third of the windows across the street glow warm (`night` uniform in `shaders/facade.gdshader`, chosen by a hash of the window's grid cell), and the street-lamp heads (`D_LampHead*`) glow.
  - The ambient light comes from the sky colours (the environment's ambient source is the sky), so the sky presets set the ambient tint as well.
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
- **Never launch a live Godot game instance** (`play_scene`, running the main scene, opening the editor to play it) unless the user asks. They said so on 2026-09-27: "do not launch a Godot live game instance, ever". This replaces the old habit of checking every visual change with a game screenshot. Use only non-visual checks (script output, `--headless --import`, `--check-only`), and say plainly what is unverified. If a look ever has to be judged, the way used earlier was `get_game_screenshot`, which saves a PNG to `%APPDATA%\Godot\app_userdata\room-godot\mcp_screenshot_res.png` (easier to read than the base64 reply) after waiting 10 to 20 seconds; do that only if asked.
- The GI bake opens a windowed Godot for a few seconds. It is not settled whether that counts as a live game instance, so ask before running it.
- After any change to lights or room geometry, re-bake the GI (see the Godot section). The bake data is git-ignored.
- The user cares most about surface materials and lighting. Prefer effort there over more geometry. Keep the mood subtle, not extreme.
- `PROJECT.md` is the only project document besides `STYLE_ANALYSIS.md`. The user steers it: edit it only when asked, and say when a change makes it stale. Do not create a separate file for a piece of furniture (`SEATING_HERO.md` was deleted on 2026-09-27 because it had served its purpose).
- On floor and rug purchases: upkeep (waterproof, no crumb traps, wash rarely, stains must not ruin it) is priority number one, and the user wants short, simple explanations and a checklist rather than expert jargon (they have never done a job like this).
- Rug choices are judged against the filters in `rug_spec_tags.txt`. A product photo for the Godot model is a look reference, not a purchase decision.
