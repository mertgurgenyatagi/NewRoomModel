"""Adds the daybed (seating hero) to room.blend, then saves it.

Run headless:  blender -b room.blend --python tools/add_daybed.py
Idempotent: every object it creates is named S_*, and old S_* objects are removed first.
Blender axes: +X right of the plan, window wall at Y = 5.25, left wall at X = 0, floor Z = 0.

Sizes are the REAL sizes (see the "Seating hero" section of PROJECT.md), even though the room around them is still at the old
0.75 m per tile scale and so about 13% too big. Move or resize the bed with the constants below.
Still guesses: the frame board height and the mattress colour. The kilim's flat colour is the
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
FRAME_H = 0.40                               # floor to the underside of the mattress (measured)
# The real frame (photos in actual_room/): a white board along each side under the mattress, on short black metal
# legs. The board height and the leg size are read off the photos, not measured. Check them with a tape.
PANEL_H, PANEL_T = 0.22, 0.02                # white side board: height under the mattress, thickness
LEG = 0.035                                  # black metal leg, square; it runs from the floor up to the board
X0 = 0.02                                    # back of the bed: left wall (X 0) plus its 1.2 cm skirting
Y_CENTRE = 3.525                             # middle of the main room (Y 1.8 to 5.25)
KILIM_T = 0.008                              # kilim thickness (thin flat weave, under 6 mm pile)
# The arm rests: two identical oak boxes, one at each end of the bed, outside the mattress and standing on the floor.
# 90 cm wide like the bed, so they hide the frame boards and the mattress ends. Recessed plinth, box-joint corners,
# a lift-off lid with a rounded edge and a finger notch (no handle). Hollow inside, for a pillow and blankets.
BOX_T, BOX_H = 0.30, 0.70                    # depth along the wall, height from the floor (arm top is 13 cm above the seat)
BOX_WALL, BOX_LID = 0.018, 0.025             # wall and lid thickness
PLINTH_H, PLINTH_IN = 0.05, 0.03             # recessed base: height, how far it sits back from the box
LID_OV = 0.010                               # lid overhang on every side
FINGER = 0.08                                # height of one box-joint finger
STAG = 0.0015                                # how far alternate fingers stand proud, so the joint reads
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


PANEL = mat("BedFrameWhite", "#e6e4de", 0.45)
BLACK_METAL = bpy.data.materials["Frame"]  # the dark metal already used for the window frame
MATTRESS = mat("Mattress", "#ddd7c9", 0.9)
KILIM = mat("Kilim", "#c3b1a6", 0.95)

# ---- frame: a white board on each side, a thin deck, four short black metal legs ----
zp0 = FRAME_H - PANEL_H
T = PANEL_T
box("Bed_Board_Back", X0, X0 + T, Y0, Y1, zp0, FRAME_H, PANEL, 0.003)
box("Bed_Board_Front", X1 - T, X1, Y0, Y1, zp0, FRAME_H, PANEL, 0.003)
box("Bed_Board_End0", X0 + T, X1 - T, Y0, Y0 + T, zp0, FRAME_H, PANEL, 0.003)
box("Bed_Board_End1", X0 + T, X1 - T, Y1 - T, Y1, zp0, FRAME_H, PANEL, 0.003)
box("Bed_Deck", X0 + T, X1 - T, Y0 + T, Y1 - T, FRAME_H - 0.02, FRAME_H, PANEL)
# legs sit just inside the boards, at the corners
for i, (lx, ly) in enumerate([(X0 + T, Y0 + T), (X1 - T - LEG, Y0 + T), (X0 + T, Y1 - T - LEG), (X1 - T - LEG, Y1 - T - LEG)]):
    box(f"Bed_Leg{i}", lx, lx + LEG, ly, ly + LEG, 0.0, zp0, BLACK_METAL, 0.003)

# ---- mattress, softly rounded ------------------------------------------
box("Bed_Mattress", X0, X1, Y0, Y1, Z_MAT0, Z_MAT1, MATTRESS, 0.03, 3)

# ---- kilim: over the top and down the whole front face -----------------
t = KILIM_T
box("Kilim_Top", X0, X1, Y0, Y1, Z_MAT1, Z_MAT1 + t, KILIM, 0.003)
box("Kilim_Front", X1, X1 + t, Y0, Y1, Z_MAT0, Z_MAT1 + t, KILIM, 0.003)

# ---- arm rests: two identical oak boxes ----------------------------------
OAK = mat("ArmBoxOak", "#c8975f", 0.55)
W = BOX_WALL
z_body0 = PLINTH_H + W                       # top of the floor plate
z_lid0 = BOX_H - BOX_LID                     # underside of the lid
n_fing = max(1, round((z_lid0 - z_body0) / FINGER))
h_fing = (z_lid0 - z_body0) / n_fing


def apply_modifiers(obj):
    bpy.context.view_layer.objects.active = obj
    for m in list(obj.modifiers):
        bpy.ops.object.modifier_apply(modifier=m.name)


for n, (ya, yb) in enumerate([(Y0 - BOX_T, Y0), (Y1, Y1 + BOX_T)]):
    b = f"ArmBox{n}"
    box(f"{b}_Plinth", X0 + PLINTH_IN, X1 - PLINTH_IN, ya + PLINTH_IN, yb - PLINTH_IN, 0.0, PLINTH_H, OAK, 0.003)
    box(f"{b}_Floor", X0, X1, ya, yb, PLINTH_H, z_body0, OAK, 0.004)
    # four walls between the corner columns
    box(f"{b}_Wall_Back", X0, X0 + W, ya + W, yb - W, z_body0, z_lid0, OAK, 0.004)
    box(f"{b}_Wall_Front", X1 - W, X1, ya + W, yb - W, z_body0, z_lid0, OAK, 0.004)
    box(f"{b}_Wall_End0", X0 + W, X1 - W, ya, ya + W, z_body0, z_lid0, OAK, 0.004)
    box(f"{b}_Wall_End1", X0 + W, X1 - W, yb - W, yb, z_body0, z_lid0, OAK, 0.004)
    # corner columns built from alternating fingers (box joints): even fingers stand proud on the long faces,
    # odd fingers on the end faces
    for ci, (cx, cy) in enumerate([(X0, ya), (X1 - W, ya), (X0, yb - W), (X1 - W, yb - W)]):
        for k in range(n_fing):
            za, zb = z_body0 + k * h_fing, z_body0 + (k + 1) * h_fing
            x0, x1, y0, y1 = cx, cx + W, cy, cy + W
            if k % 2 == 0:
                x0, x1 = (x0 - STAG, x1) if cx == X0 else (x0, x1 + STAG)
            else:
                y0, y1 = (y0 - STAG, y1) if cy == ya else (y0, y1 + STAG)
            box(f"{b}_Joint{ci}_{k}", x0, x1, y0, y1, za, zb, OAK, 0.003)
    # lid, with a half-round finger notch cut into the edge that faces the room
    lid = box(f"{b}_Lid", X0 - LID_OV, X1 + LID_OV, ya - LID_OV, yb + LID_OV, z_lid0, BOX_H, OAK, 0.010, 4)
    cbm = bmesh.new()
    bmesh.ops.create_cone(cbm, cap_ends=True, segments=24, radius1=0.024, radius2=0.024, depth=BOX_LID + 0.02)
    cme = bpy.data.meshes.new("S_" + b + "_Cutter")
    cbm.to_mesh(cme)
    cbm.free()
    cut = bpy.data.objects.new("S_" + b + "_Cutter", cme)
    cut.location = (X1 + LID_OV, (ya + yb) / 2, z_lid0 + BOX_LID / 2)
    ROOM.objects.link(cut)
    bo = lid.modifiers.new("Notch", 'BOOLEAN')
    bo.operation, bo.object, bo.solver = 'DIFFERENCE', cut, 'EXACT'
    try:
        apply_modifiers(lid)
        print("NOTCH_OK", b)
    except Exception as e:  # keep the lid without a notch rather than fail the whole build
        print("NOTCH_FAILED", b, e)
        for m in list(lid.modifiers):
            lid.modifiers.remove(m)
    bpy.data.objects.remove(cut, do_unlink=True)

bpy.ops.wm.save_mainfile()
print("DAYBED_DONE", len([o for o in bpy.data.objects if o.name.startswith("S_")]))
