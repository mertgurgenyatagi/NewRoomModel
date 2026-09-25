"""Adds the missing photo details and a livelier street to room.blend, then saves it.

Run headless:  blender -b room.blend --python tools/add_room_detail.py
Idempotent: every object it creates is named D_*, and old D_* objects are removed first.
Blender axes: +X right of the plan, window wall at Y = 5.25, floor Z = 0, ceiling Z = 2.6.
"""
import bmesh
import bpy


def lin(h):
    h = h.lstrip('#')
    r, g, b = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return (f(r), f(g), f(b), 1.0)


# ---- clean previous run -------------------------------------------------
for o in [o for o in bpy.data.objects if o.name.startswith("D_")]:
    bpy.data.objects.remove(o, do_unlink=True)
for m in [m for m in bpy.data.meshes if m.name.startswith("D_") and m.users == 0]:
    bpy.data.meshes.remove(m)

ROOM = bpy.data.collections["Room"]
EXT = bpy.data.collections["Exterior"]

_mats = {}


def mat(name, hexc, rough=0.6, metal=0.0):
    if name in _mats:
        return _mats[name]
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Base Color"].default_value = lin(hexc)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    _mats[name] = m
    return m


def _link(o, coll, m):
    coll.objects.link(o)
    o.data.materials.append(m)
    return o


def box(name, x0, x1, y0, y1, z0, z1, m, coll=ROOM):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    me = bpy.data.meshes.new("D_" + name)
    bm.to_mesh(me)
    bm.free()
    return _link(bpy.data.objects.new("D_" + name, me), coll, m)


def cyl(name, cx, cy, z0, z1, r, m, coll=ROOM, seg=16, axis='Z'):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=r, radius2=r, depth=z1 - z0)
    for v in bm.verts:
        v.co.z += (z1 - z0) / 2
    me = bpy.data.meshes.new("D_" + name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("D_" + name, me)
    o.location = (cx, cy, z0)
    if axis == 'X':
        o.rotation_euler = (0, 1.5708, 0)
    return _link(o, coll, m)


def sphere(name, cx, cy, cz, r, m, coll=EXT):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=r)
    me = bpy.data.meshes.new("D_" + name)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    o = bpy.data.objects.new("D_" + name, me)
    o.location = (cx, cy, cz)
    return _link(o, coll, m)


SKIRT = mat("Skirting", "#d8d4cd", 0.6)
STEEL = mat("Steel", "#b4b7ba", 0.38, 0.35)  # satin, only partly metallic so it does not just mirror the sky
DARKSTEEL = mat("DarkSteel", "#7d8186", 0.4, 0.3)
WHITE = mat("Radiator", "#ecebe6", 0.4)
PLATE = mat("SocketPlate", "#efeee9", 0.5)
CURTAIN = mat("Curtain", "#5a3d2b", 0.95)
FRAME = bpy.data.materials["Frame"]
CNTR = bpy.data.materials["CounterWhite"]
CNTR_FRONT = mat("CounterFront", "#e3e2dc", 0.35)
BLACK = mat("BlackPlastic", "#1a1a1a", 0.5)
BARK = mat("Bark", "#4a3b2e", 0.9)
LEAF = mat("Leaves", "#5f7a3a", 0.85)
LEAF2 = mat("Leaves2", "#728a45", 0.85)
LAMP = mat("LampPole", "#3c4044", 0.5, 0.6)

# ---- skirting boards (h 8 cm, 1.2 cm thick) ------------------------------
H, T = 0.08, 0.012
box("Skirt_Left", 0, T, 0, 5.25, 0, H, SKIRT)
box("Skirt_HallRight", 1.312 - T, 1.312, 0, 1.8, 0, H, SKIRT)
box("Skirt_Step", 1.312, 3.112, 1.8, 1.8 + T, 0, H, SKIRT)
box("Skirt_Right", 3.112 - T, 3.112, 1.8, 5.25, 0, H, SKIRT)
box("Skirt_EntR", 1.0, 1.312, 0, T, 0, H, SKIRT)
box("Skirt_PierL", 0, 0.1, 5.25 - T, 5.25, 0, H, SKIRT)
box("Skirt_PierR", 3.013, 3.112, 5.25 - T, 5.25, 0, H, SKIRT)

# ---- window frame (dark), around the glass at Y 5.3 ----------------------
box("WinFrame_L", 0.1, 0.125, 5.26, 5.34, 0.05, 2.45, FRAME)
box("WinFrame_R", 2.988, 3.013, 5.26, 5.34, 0.05, 2.45, FRAME)
box("WinFrame_Top", 0.1, 3.013, 5.26, 5.34, 2.425, 2.45, FRAME)
box("WinFrame_Mullion", 1.5, 1.525, 5.28, 5.33, 0.05, 2.425, FRAME)
box("WinFrame_Rail", 0.1, 3.013, 5.28, 5.33, 1.05, 1.08, FRAME)

# ---- panel radiator in front of the window (ribbed) ----------------------
box("Rad_Back", 1.6, 2.5, 5.19, 5.22, 0.12, 0.72, WHITE)
for i in range(11):
    x = 1.62 + i * 0.08
    box(f"Rad_Rib{i}", x, x + 0.06, 5.14, 5.19, 0.12, 0.72, WHITE)
box("Rad_Pipe1", 1.62, 1.66, 5.19, 5.23, 0.04, 0.12, STEEL)
box("Rad_Pipe2", 2.44, 2.48, 5.19, 5.23, 0.04, 0.12, STEEL)

# ---- heavy brown curtain, gathered at the right pier ---------------------
for i in range(9):
    x = 2.55 + i * 0.052
    d = 0.0 if i % 2 == 0 else 0.03
    box(f"Curtain{i}", x, x + 0.05, 5.10 + d, 5.24 - (0.03 - d), 0.02, 2.44, CURTAIN)
box("Curtain_Rod", 2.5, 3.013, 5.2, 5.24, 2.44, 2.46, DARKSTEEL)

# ---- door handle (room side of the door) ---------------------------------
box("Door_Rose", 0.865, 0.905, -0.02, 0.005, 0.98, 1.06, STEEL)
box("Door_Lever", 0.70, 0.905, 0.005, 0.03, 1.005, 1.035, STEEL)
cyl("Door_Lock", 0.885, -0.005, 0.86, 0.9, 0.012, STEEL, seg=12)
# make the lock cylinder face the room (rotate to lie along Y)
lk = bpy.data.objects["D_Door_Lock"]
lk.rotation_euler = (1.5708, 0, 0)
lk.location = (0.885, 0.0, 0.88)

# ---- sockets, light switch, smoke detector -------------------------------
def socket(name, x, y, z, face):
    """face: 'x+' plate on a wall whose interior is at +x; 'x-' at -x; 'y+' interior at +y."""
    s, w = 0.012, 0.04
    if face == 'x+':
        box(name, x, x + s, y - w, y + w, z - w, z + w, PLATE)
    elif face == 'x-':
        box(name, x - s, x, y - w, y + w, z - w, z + w, PLATE)
    else:
        box(name, x - w, x + w, y, y + s, z - w, z + w, PLATE)


socket("Sock1", 0.0, 2.6, 0.30, 'x+')
socket("Sock2", 0.0, 4.5, 0.30, 'x+')
socket("Sock3", 3.112, 4.4, 0.30, 'x-')
socket("Sock4", 3.112, 3.3, 0.30, 'x-')
socket("Sock5", 3.112, 2.4, 1.10, 'x-')
socket("Switch", 1.15, 0.0, 1.20, 'y+')
box("SmokeDetector", 1.55 - 0.055, 1.55 + 0.055, 3.4 - 0.055, 3.4 + 0.055, 2.57, 2.6, PLATE)

# ---- mini kitchen counter details ---------------------------------------
# Body X 1.688..3.112, Y 1.8..2.625, Z 0.06..0.85; front faces +Y (room).
FY = 2.625
box("Fridge_Door", 1.70, 2.22, FY, FY + 0.012, 0.09, 0.83, CNTR_FRONT)
box("Fridge_Handle", 2.16, 2.18, FY + 0.012, FY + 0.04, 0.45, 0.78, STEEL)
box("Cab_DoorL", 2.245, 2.655, FY, FY + 0.012, 0.09, 0.83, CNTR_FRONT)
box("Cab_DoorR", 2.675, 3.10, FY, FY + 0.012, 0.09, 0.83, CNTR_FRONT)
box("Cab_HandleL", 2.60, 2.62, FY + 0.012, FY + 0.04, 0.60, 0.80, STEEL)
box("Cab_HandleR", 2.71, 2.73, FY + 0.012, FY + 0.04, 0.60, 0.80, STEEL)
box("Counter_Edge", 1.668, 3.112, 2.635, 2.648, 0.85, 0.88, STEEL)
box("Sink_Plate", 2.30, 2.95, 1.92, 2.52, 0.878, 0.884, STEEL)
box("Sink_Basin", 2.36, 2.90, 1.98, 2.46, 0.872, 0.885, DARKSTEEL)
cyl("Tap_Stem", 2.63, 1.90, 0.878, 1.13, 0.014, STEEL, seg=12)
box("Tap_Spout", 2.616, 2.644, 1.90, 2.12, 1.10, 1.13, STEEL)
box("Tap_Lever", 2.63, 2.64, 1.88, 1.90, 1.05, 1.12, STEEL)
for i, (lx, ly) in enumerate([(1.74, 1.86), (3.06, 1.86), (1.74, 2.57), (3.06, 2.57)]):
    cyl(f"Leg{i}", lx, ly, 0.0, 0.06, 0.02, BLACK, seg=10)

# ---- street life: trees, lamps, cars ------------------------------------
# Near sidewalk centre Y ~6.3, top Z ~ -12.0; road Y 7.25..17.25; far sidewalk to Y 19.75.
ZS = -12.0
for i, x in enumerate([-13.0, -3.5, 5.5, 14.0]):
    cyl(f"TreeTrunk{i}", x, 6.3, ZS, ZS + 3.2, 0.13, BARK, EXT, seg=10)
    sphere(f"TreeCrown{i}a", x, 6.3, ZS + 4.6, 1.9, LEAF if i % 2 == 0 else LEAF2)
    sphere(f"TreeCrown{i}b", x + 0.9, 6.5, ZS + 3.9, 1.3, LEAF2)
    sphere(f"TreeCrown{i}c", x - 0.8, 6.0, ZS + 4.0, 1.4, LEAF)

for i, x in enumerate([-15.0, -1.0, 12.0]):
    cyl(f"LampPole{i}", x, 17.6, ZS, ZS + 7.0, 0.07, LAMP, EXT, seg=10)
    box(f"LampArm{i}", x - 0.04, x + 0.04, 16.4, 17.6, ZS + 6.9, ZS + 7.0, LAMP, EXT)
    box(f"LampHead{i}", x - 0.15, x + 0.15, 16.2, 16.7, ZS + 6.82, ZS + 6.92, LAMP, EXT)

CARS = [(-11.0, 8.7, "#d9d9d6"), (-2.0, 8.7, "#2c3036"), (7.0, 8.7, "#8e2b25"),
        (-6.0, 15.4, "#a8adb3"), (10.0, 15.4, "#2f4a6b")]
for i, (x, y, hexc) in enumerate(CARS):
    body = mat(f"Car{i}", hexc, 0.35, 0.5)
    base = -12.05 + 0.22
    box(f"CarBody{i}", x - 2.1, x + 2.1, y - 0.9, y + 0.9, base, base + 0.7, body, EXT)
    box(f"CarCabin{i}", x - 1.1, x + 1.0, y - 0.8, y + 0.8, base + 0.7, base + 1.3, mat("CarGlass", "#20262c", 0.1, 0.0), EXT)
    for wx in (-1.3, 1.3):
        for wy in (-0.85, 0.85):
            w = cyl(f"CarWheel{i}_{wx}_{wy}", 0, 0, 0.0, 0.25, 0.3, BLACK, EXT, seg=12)
            w.rotation_euler = (1.5708, 0, 0)  # local +Z maps to -Y, so offset by half the width
            w.location = (x + wx, y + wy + 0.125, -12.05 + 0.3)


# ---- bevel every small fixture and the counter so edges catch light -----------
def bevel(o, width, segments=2):
    m = o.modifiers.new("Bevel", 'BEVEL')
    m.width = width
    m.segments = segments
    m.limit_method = 'ANGLE'


for o in bpy.data.objects:
    if o.name.startswith("D_") and o.type == 'MESH' and o.parent is None and o.name.startswith(
            ("D_Fridge", "D_Cab_", "D_Counter_", "D_Sink", "D_Tap", "D_Rad", "D_Door_", "D_Sock", "D_Switch", "D_Smoke", "D_Skirt", "D_WinFrame", "D_Curtain_Rod")):
        bevel(o, 0.004 if o.name.startswith(("D_Sock", "D_Switch", "D_Tap", "D_Door_Lock", "D_Smoke")) else 0.006)
for name, w in (("Counter_Body", 0.012), ("Counter_Top", 0.006)):
    o = bpy.data.objects[name]
    if not any(m.type == 'BEVEL' for m in o.modifiers):
        bevel(o, w, 3)

bpy.ops.wm.save_mainfile()
print("DETAIL_DONE", len([o for o in bpy.data.objects if o.name.startswith("D_")]))
