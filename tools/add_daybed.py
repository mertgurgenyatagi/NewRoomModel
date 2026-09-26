"""Adds the daybed (seating hero) to room.blend, then saves it.

Run headless:  blender -b room.blend --python tools/add_daybed.py
Idempotent: every object it creates is named S_*, and old S_* objects are removed first.
Blender axes: +X right of the plan, window wall at Y = 5.25, left wall at X = 0, floor Z = 0.

Sizes are the REAL sizes (see SEATING_HERO.md), even though the room around them is still at the old
0.75 m per tile scale and so about 13% too big. Move or resize the bed with the constants below.
Placeholders that are still guesses: the frame's look and colour, and the mattress colour. The kilim's flat colour is the
average of kilim-texture.png (the GI bake reads it); its look in Godot comes from shaders/kilim.gdshader.
"""
import bmesh
import bpy


def lin(h):
    h = h.lstrip('#')
    r, g, b = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return (f(r), f(g), f(b), 1.0)


# ---- the daybed, in metres ----------------------------------------------
MAT_W, MAT_L, MAT_H = 0.90, 1.90, 0.17      # mattress: across (X), along the wall (Y), thickness
FRAME_H = 0.40                               # floor to the underside of the mattress (frame legs)
LEG = 0.05                                   # frame leg, square
RAIL_H, RAIL_T = 0.09, 0.03                  # frame rail band under the mattress
X0 = 0.02                                    # back of the bed: left wall (X 0) plus its 1.2 cm skirting
Y_CENTRE = 3.525                             # middle of the main room (Y 1.8 to 5.25)
KILIM_T = 0.008                              # kilim thickness (thin flat weave, under 6 mm pile)
# The kilim is 110 x 190 cm: it runs the full length and covers the top and the whole front face.
# Top 0.90 + front drop 0.17 = 1.07, so about 3 cm is left to tuck under.

Y0, Y1 = Y_CENTRE - MAT_L / 2, Y_CENTRE + MAT_L / 2
X1 = X0 + MAT_W
Z_MAT0 = FRAME_H
Z_MAT1 = FRAME_H + MAT_H

# ---- clean previous run -------------------------------------------------
for o in [o for o in bpy.data.objects if o.name.startswith("S_")]:
    bpy.data.objects.remove(o, do_unlink=True)
for m in [m for m in bpy.data.meshes if m.name.startswith("S_") and m.users == 0]:
    bpy.data.meshes.remove(m)

ROOM = bpy.data.collections["Room"]


def mat(name, hexc, rough=0.6, metal=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Base Color"].default_value = lin(hexc)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    return m


def box(name, x0, x1, y0, y1, z0, z1, m, bevel=0.0, segments=2):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    me = bpy.data.meshes.new("S_" + name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("S_" + name, me)
    ROOM.objects.link(o)
    o.data.materials.append(m)
    if bevel > 0:
        b = o.modifiers.new("Bevel", 'BEVEL')
        b.width = bevel
        b.segments = segments
        b.limit_method = 'ANGLE'
    return o


WOOD = mat("BedFrameWood", "#9c7a54", 0.55)
MATTRESS = mat("Mattress", "#ddd7c9", 0.9)
KILIM = mat("Kilim", "#c3b1a6", 0.95)

# ---- frame: four legs, a rail band round the top, a thin deck ----------
for i, (lx, ly) in enumerate([(X0, Y0), (X1 - LEG, Y0), (X0, Y1 - LEG), (X1 - LEG, Y1 - LEG)]):
    box(f"Bed_Leg{i}", lx, lx + LEG, ly, ly + LEG, 0.0, FRAME_H - RAIL_H, WOOD, 0.004)
zr0 = FRAME_H - RAIL_H
box("Bed_Rail_Back", X0, X0 + RAIL_T, Y0, Y1, zr0, FRAME_H, WOOD, 0.004)
box("Bed_Rail_Front", X1 - RAIL_T, X1, Y0, Y1, zr0, FRAME_H, WOOD, 0.004)
box("Bed_Rail_End0", X0 + RAIL_T, X1 - RAIL_T, Y0, Y0 + RAIL_T, zr0, FRAME_H, WOOD, 0.004)
box("Bed_Rail_End1", X0 + RAIL_T, X1 - RAIL_T, Y1 - RAIL_T, Y1, zr0, FRAME_H, WOOD, 0.004)
box("Bed_Deck", X0 + RAIL_T, X1 - RAIL_T, Y0 + RAIL_T, Y1 - RAIL_T, FRAME_H - 0.02, FRAME_H, WOOD)

# ---- mattress, softly rounded ------------------------------------------
box("Bed_Mattress", X0, X1, Y0, Y1, Z_MAT0, Z_MAT1, MATTRESS, 0.03, 3)

# ---- kilim: over the top and down the whole front face -----------------
t = KILIM_T
box("Kilim_Top", X0, X1, Y0, Y1, Z_MAT1, Z_MAT1 + t, KILIM, 0.003)
box("Kilim_Front", X1, X1 + t, Y0, Y1, Z_MAT0, Z_MAT1 + t, KILIM, 0.003)

bpy.ops.wm.save_mainfile()
print("DAYBED_DONE", len([o for o in bpy.data.objects if o.name.startswith("S_")]))
