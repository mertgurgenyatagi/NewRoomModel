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
# The arm rests: two identical boxes, one at each end of the bed, outside the mattress and standing on the floor. 90 cm
# wide like the bed, so they hide the frame boards and the mattress ends. Hollow inside, for a pillow and blankets.
# 2026-09-27: covered in a fitted beige bouclé slipcover (see PROJECT.md, decision 27) instead of bare oak. Only the
# recessed plinth stays bare wood, like furniture feet peeking out under a loose cover; the body, corners and lid are the
# fabric. A raised band at the lid line stands in for the slipcover's zip seam.
BOX_T, BOX_H = 0.30, 0.70                    # depth along the wall, height from the floor (arm top is 13 cm above the seat)
BOX_WALL, BOX_LID = 0.018, 0.025             # wall and lid thickness (the "wood" underneath the cover)
PLINTH_H, PLINTH_IN = 0.05, 0.03             # recessed base: height, how far it sits back from the box
LID_OV = 0.010                               # lid overhang on every side
BAND_OV, BAND_H = 0.006, 0.010               # the seam band at the lid line: how far it stands proud, its height
# The kilim runs the full length and covers the top and the whole front face, all the way down to the top of the legs
# (2026-09-27: extended from just the mattress edge so the white frame board never shows).
# Top 0.90 + front drop 0.39 (mattress 0.17 + board 0.22) = 1.29 m needed across the roll's width.
# The 110 x 190 cm kilim picked earlier (see PROJECT.md, SHOPPING_LIST.md) is 19 cm short of that: it will cover the top and
# most of the front, but not reach the legs. Either size up the kilim or dress the board separately; not decided.

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

# ---- kilim: over the top, and down the front all the way to the top of the legs, so the white board never shows --------
t = KILIM_T
box("Kilim_Top", X0, X1, Y0, Y1, Z_MAT1, Z_MAT1 + t, KILIM, 0.003)
box("Kilim_Front", X1, X1 + t, Y0, Y1, zp0, Z_MAT1 + t, KILIM, 0.003)

# ---- arm rests: two identical boxes, fabric-covered body and lid, bare oak plinth ----
OAK = mat("ArmBoxOak", "#c8975f", 0.55)            # the plinth only: a sliver of real wood peeking out at the floor
FABRIC = mat("ArmBoxFabric", "#c9bda0", 0.9)       # the slipcover: beige bouclé, flat colour here (see shaders/fabric.gdshader)
W = BOX_WALL
z_body0 = PLINTH_H + W                       # top of the floor plate
z_lid0 = BOX_H - BOX_LID                     # underside of the lid


def apply_modifiers(obj):
    bpy.context.view_layer.objects.active = obj
    for m in list(obj.modifiers):
        bpy.ops.object.modifier_apply(modifier=m.name)


for n, (ya, yb) in enumerate([(Y0 - BOX_T, Y0), (Y1, Y1 + BOX_T)]):
    b = f"ArmBox{n}"
    box(f"{b}_Plinth", X0 + PLINTH_IN, X1 - PLINTH_IN, ya + PLINTH_IN, yb - PLINTH_IN, 0.0, PLINTH_H, OAK, 0.003)
    box(f"{b}_Floor", X0, X1, ya, yb, PLINTH_H, z_body0, OAK, 0.004)     # hidden inside the box; material doesn't matter
    # four walls, softly rounded at their edges like a padded surface, not a sharp wooden crate
    box(f"{b}_Wall_Back", X0, X0 + W, ya + W, yb - W, z_body0, z_lid0, FABRIC, 0.006)
    box(f"{b}_Wall_Front", X1 - W, X1, ya + W, yb - W, z_body0, z_lid0, FABRIC, 0.006)
    box(f"{b}_Wall_End0", X0 + W, X1 - W, ya, ya + W, z_body0, z_lid0, FABRIC, 0.006)
    box(f"{b}_Wall_End1", X0 + W, X1 - W, yb - W, yb, z_body0, z_lid0, FABRIC, 0.006)
    # plain corner columns (the wood box-joint is gone: it would never show under a fabric cover)
    for ci, (cx, cy) in enumerate([(X0, ya), (X1 - W, ya), (X0, yb - W), (X1 - W, yb - W)]):
        box(f"{b}_Corner{ci}", cx, cx + W, cy, cy + W, z_body0, z_lid0, FABRIC, 0.006)
    # a raised band right at the lid line, standing for the slipcover's zip seam
    box(f"{b}_SeamBand", X0 - BAND_OV, X1 + BAND_OV, ya - BAND_OV, yb + BAND_OV,
        z_lid0 - BAND_H / 2, z_lid0 + BAND_H / 2, FABRIC, 0.004, 3)
    # lid, generously rounded (a cushioned top, not a wooden lid), with a half-round finger notch to lift it (no handle)
    lid = box(f"{b}_Lid", X0 - LID_OV, X1 + LID_OV, ya - LID_OV, yb + LID_OV, z_lid0, BOX_H, FABRIC, 0.014, 4)
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

# ---- back support: two long firm foam cushions in sage covers (day position, against the wall) ----
# Modelled as covered blocks, not boxes: a rounded body with the fabric puffed out on each face, faint wrinkles, and a welt
# (piping cord) round the top and bottom seams. The foam is assumed perfect and the covers are the sage "kilif" of the plan.
import math
import random
from mathutils import Vector, noise

BACK_D, BACK_H = 0.40, 0.50                  # depth off the wall (leaves a 50 cm seat) and height above the seat
BACK_GAP = 0.0125                            # gap between neighbouring blocks
N_BACK = 2                                   # three near-cube blocks read as ottomans; two long ones read as a sofa back
BACK_W = (MAT_L - (N_BACK - 1) * BACK_GAP) / N_BACK
BACK_R = 0.035                               # corner radius of a covered block
WELT_R = 0.0075                              # piping cord radius
BEIGE = mat("CushionBeige", "#c0b198", 0.95)      # the back blocks: warm linen beige
SAGE = mat("CushionSage", "#78876c", 0.95)        # the scatter pillows


def smooth(o):
    o.data.polygons.foreach_set("use_smooth", [True] * len(o.data.polygons))
    o.data.update()


def rounded_block(name, cx, cy, z0, sx, sy, sz, r, puff, seed, m):
    """A rounded box, centred on (cx, cy) with its base at z0. puff = bulge of the fabric on (+x, -x, +y, -y, +z, -z)."""
    hx, hy, hz = sx / 2, sy / 2, sz / 2
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=26, use_grid_fill=True)
    half = Vector((hx, hy, hz))
    for v in bm.verts:
        q = Vector((v.co.x * sx, v.co.y * sy, v.co.z * sz))     # on the box surface
        # rounded box: pull each vertex onto a sphere of radius r around the clamped inner point
        inner = Vector((max(-hx + r, min(hx - r, q.x)), max(-hy + r, min(hy - r, q.y)), max(-hz + r, min(hz - r, q.z))))
        d = q - inner
        p = inner + d.normalized() * r if d.length > 1e-9 else q
        # fabric puff on each face, zero along the edges so the seams stay tight
        for a, b_, c_ in ((0, 1, 2), (1, 0, 2), (2, 0, 1)):
            if abs(abs(q[a]) - half[a]) < 1e-6:
                s = 1 if q[a] > 0 else -1
                k = puff[a * 2 + (0 if s > 0 else 1)]
                p[a] += s * k * (1 - (q[b_] / half[b_]) ** 2) * (1 - (q[c_] / half[c_]) ** 2)
        # fine pulled-fabric wrinkles only: tiny amplitude, small scale, a little stronger near the corners where the cover gathers.
        # (Big slow noise here made the blocks look like jelly.)
        n = d.normalized() if d.length > 1e-9 else Vector((0, 0, 0))
        edge = 1 - min(1.0, min(half[0] - abs(q[0]), half[1] - abs(q[1]), half[2] - abs(q[2])) / 0.08)
        w = noise.noise(Vector((p.x * 45 + seed, p.y * 45, p.z * 45)))
        p += n * (w * (0.0006 + 0.0016 * edge))
        v.co = Vector((p.x + cx, p.y + cy, p.z + z0 + hz))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new("S_" + name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("S_" + name, me)
    ROOM.objects.link(o)
    o.data.materials.append(m)
    smooth(o)
    return o


def welt(name, cx, cy, zc, hx, hy, r, sign, m, seg=10, prof=8):
    """Piping cord round a seam: a tube following the rounded rectangle at 45 degrees on the top (+1) or bottom (-1) edge."""
    c45 = math.cos(math.radians(45))
    ix, iy = hx - r, hy - r
    pts = []
    for (ox, oy, a0) in ((ix, iy, 0), (-ix, iy, 90), (-ix, -iy, 180), (ix, -iy, 270)):
        for k in range(seg + 1):
            a = math.radians(a0 + 90 * k / seg)
            pts.append(Vector((ox + r * c45 * math.cos(a), oy + r * c45 * math.sin(a), sign * (zc + r * c45))))
    bm = bmesh.new()
    rings = []
    n = len(pts)
    for i, p in enumerate(pts):
        t = (pts[(i + 1) % n] - pts[i - 1]).normalized()
        up = Vector((0, 0, 1))
        s_ = t.cross(up).normalized()
        u_ = s_.cross(t).normalized()
        ring = []
        for j in range(prof):
            ang = 2 * math.pi * j / prof
            ring.append(bm.verts.new(p + s_ * (WELT_R * math.cos(ang)) + u_ * (WELT_R * math.sin(ang))))
        rings.append(ring)
    for i in range(n):
        a, b = rings[i], rings[(i + 1) % n]
        for j in range(prof):
            bm.faces.new((a[j], a[(j + 1) % prof], b[(j + 1) % prof], b[j]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new("S_" + name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("S_" + name, me)
    o.location = (cx, cy, 0)
    ROOM.objects.link(o)
    o.data.materials.append(m)
    smooth(o)
    return o


z_seat = Z_MAT1 + KILIM_T
for i in range(N_BACK):
    cy = Y0 + BACK_W / 2 + i * (BACK_W + BACK_GAP)
    cx = X0 + BACK_D / 2
    # puff order: +x (the visible front), -x (against the wall), +y, -y, +z, -z. The end faces are squeezed by the neighbour.
    rounded_block(f"Back{i}_Body", cx, cy, z_seat, BACK_D, BACK_W, BACK_H, BACK_R,
                  (0.008, 0.002, 0.004, 0.004, 0.007, 0.0), 11.0 + i * 7.3, BEIGE)
    # the welts sit on the 45 degree line of the top and bottom edge, measured from the block's middle height
    for nm, sg in (("WeltTop", 1), ("WeltBot", -1)):
        w = welt(f"Back{i}_{nm}", cx, cy, BACK_H / 2 - BACK_R, BACK_D / 2, BACK_W / 2, BACK_R, sg, BEIGE)
        w.location.z = z_seat + BACK_H / 2


# ---- three sage scatter pillows, leaning in different places ----
from mathutils import Quaternion


def pillow(name, size, thick, facing, tilt_deg, roll_deg, seed, m, pin):
    """A square scatter pillow: a lens-shaped body with a thin seam round the edge and pinched corners (the 'ears').
    facing = horizontal direction its face points; tilt_deg = how far the face tips up (0 = standing, 90 = lying).
    pin = {"minx"|"maxx"|"miny"|"maxy": value, ...} pushes the finished pillow against a surface; it always rests on the seat."""
    hs = size / 2
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=22, use_grid_fill=True)
    pts = []
    for v in bm.verts:
        u, w_, k = v.co.x * 2, v.co.y * 2, v.co.z * 2        # each in -1 .. 1
        t = (max(0.0, 1 - u * u) ** 0.5) * (max(0.0, 1 - w_ * w_) ** 0.5)
        t = t ** 0.75
        z = k * (thick / 2 * t + 0.005)
        # stuffing pulls the edges in more at the middle of each side than at the corners, so the corners stick out
        sx = 1 - 0.09 * (max(0.0, 1 - w_ * w_) ** 0.5) * (max(0.0, 1 - u * u) ** 0.35)
        sy = 1 - 0.09 * (max(0.0, 1 - u * u) ** 0.5) * (max(0.0, 1 - w_ * w_) ** 0.35)
        x, y = u * hs * sx, w_ * hs * sy
        # a soft crease from each corner toward the middle, and a little fabric noise
        corner = (abs(u) * abs(w_)) ** 3
        z += k * 0.006 * corner * math.sin(9 * (abs(u) - abs(w_)) + seed)
        z += k * noise.noise(Vector((x * 22 + seed, y * 22, 0.0))) * 0.0035 * t
        pts.append((v, Vector((x, y, z))))
    for v, pos in pts:
        v.co = pos
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    fx, fy = facing
    a = math.radians(tilt_deg)
    nrm = Vector((fx * math.cos(a), fy * math.cos(a), math.sin(a))).normalized()
    rot = nrm.to_track_quat('Z', 'Y') @ Quaternion(Vector((0, 0, 1)), math.radians(roll_deg))
    for v in bm.verts:
        v.co = rot @ v.co
    lo = Vector((min(v.co.x for v in bm.verts), min(v.co.y for v in bm.verts), min(v.co.z for v in bm.verts)))
    hi = Vector((max(v.co.x for v in bm.verts), max(v.co.y for v in bm.verts), max(v.co.z for v in bm.verts)))
    dx = dy = 0.0
    if "minx" in pin: dx = pin["minx"] - lo.x
    if "maxx" in pin: dx = pin["maxx"] - hi.x
    if "miny" in pin: dy = pin["miny"] - lo.y
    if "maxy" in pin: dy = pin["maxy"] - hi.y
    dz = z_seat + 0.004 - lo.z
    if "cx" in pin: dx = pin["cx"] - (lo.x + hi.x) / 2
    if "cy" in pin: dy = pin["cy"] - (lo.y + hi.y) / 2
    for v in bm.verts:
        v.co += Vector((dx, dy, dz))
    me = bpy.data.meshes.new("S_" + name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("S_" + name, me)
    ROOM.objects.link(o)
    o.data.materials.append(m)
    smooth(o)
    return o


x_face = X0 + BACK_D + 0.010                 # front of the back blocks, with their puff
# one against the near arm box, one on the back blocks over the middle, one against the far arm box
pillow("Pillow0", 0.42, 0.13, (0, 1), 12, 6, 3.0, SAGE, {"miny": Y0 + 0.020, "cx": 0.66})
pillow("Pillow1", 0.46, 0.14, (1, 0), 22, -14, 8.0, SAGE, {"minx": x_face, "cy": Y_CENTRE - 0.20})
pillow("Pillow2", 0.40, 0.12, (0, -1), 16, -5, 14.0, SAGE, {"maxy": Y1 - 0.020, "cx": 0.66})

bpy.ops.wm.save_mainfile()
print("DAYBED_DONE", len([o for o in bpy.data.objects if o.name.startswith("S_")]))
