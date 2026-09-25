import bpy
def lin(h):
    h=h.lstrip('#'); r,g,b=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    f=lambda c: c/12.92 if c<=0.04045 else ((c+0.055)/1.055)**2.4
    return (f(r),f(g),f(b),1.0)
# name: (hex, roughness, alpha)
M={
 "Floor":("#c9c3b9",0.45,1),"Wall":("#a7a3a2",0.9,1),"Ceiling":("#c7c3bd",0.9,1),"Soffit":("#c7c3bd",0.9,1),
 "Door":("#151412",0.15,1),"Frame":("#1c1c1e",0.4,1),"Glass":("#cfe6ee",0.0,0.12),
 "CounterWhite":("#dcdcd6",0.35,1),"CounterTop":("#1b1b1c",0.25,1),"BlindSheer":("#e0d9cc",0.9,0.55),
 "DownlightRim":("#e8e8e2",0.4,1),"DownlightLens":("#fff2d0",0.4,1),
 "Asphalt":("#2b2b2d",0.85,1),"Sidewalk":("#77716a",0.9,1),
 "Fac_Beige":("#d9c3a3",0.85,1),"Fac_Cream":("#e6d6b0",0.85,1),"Fac_Far":("#7a6c6a",1.0,1),
 "Fac_Orange":("#c9622a",0.85,1),"Fac_Pink":("#c98f78",0.85,1),"Fac_White":("#e8e4dc",0.85,1),
}
for m in bpy.data.materials:
    if not m.use_nodes: continue
    old=next((n for n in m.node_tree.nodes if n.type=="BSDF_PRINCIPLED"),None)
    if m.name in M:
        hexc,rough,alpha=M[m.name]; color=lin(hexc); metal=0.0
    elif old is not None:  # materials added by add_room_detail.py: keep their plain Principled values
        color=tuple(old.inputs["Base Color"].default_value); rough=old.inputs["Roughness"].default_value
        alpha=1.0; metal=old.inputs["Metallic"].default_value
    else: continue
    nt=m.node_tree; nt.nodes.clear()
    out=nt.nodes.new("ShaderNodeOutputMaterial"); b=nt.nodes.new("ShaderNodeBsdfPrincipled")
    b.inputs["Base Color"].default_value=color; b.inputs["Roughness"].default_value=rough
    b.inputs["Metallic"].default_value=metal
    b.inputs["Alpha"].default_value=alpha
    nt.links.new(b.outputs[0],out.inputs[0])
    if alpha<1: m.blend_method='BLEND' if hasattr(m,'blend_method') else None
bpy.ops.object.select_all(action='DESELECT')
n=0
for o in bpy.data.objects:
    if o.type!='MESH': continue
    if any(c.name=="Lights_Day" for c in o.users_collection): continue
    o.hide_set(False); o.hide_viewport=False; o.select_set(True); n+=1
print("EXPORTING",n)
bpy.ops.export_scene.gltf(filepath="C:/Users/Mert/Desktop/repos/NewRoomModel/room-godot/assets/room.glb",
    export_format='GLB',use_selection=True,export_apply=True,export_yup=True,export_cameras=False,export_lights=False)
