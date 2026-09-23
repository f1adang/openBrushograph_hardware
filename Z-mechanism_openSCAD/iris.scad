// openBrushograph - iris tool holder
// ---------------------------------------------------------------------------
// A camera-lens iris. Three identical blades pivot on posts in the base; a ring
// with three radial slots drives them all at once. Three straight blade edges at
// 120 deg are always tangent to one circle centred on the axis, so the centring
// is exact and purely geometric - nothing to couple, preload or calibrate, and
// it does not depend on force, friction, backlash or elasticity.
//
// Blades sit at three heights so they can sweep past each other, as in a real
// iris. The blades stay identical; the base's posts carry the three offsets.

/* [Capacity] */
bore_max   = 13;    // [6:0.5:25]   largest barrel
bore_slack = 0.8;   // [0:0.1:2]    insertion clearance on top of that
bore_min   = 3.2;   // [1:0.1:8]    smallest barrel it closes down to

/* [Iris geometry] */
Rp         = 14.5;  // [10:0.25:20] pivot post circle
pin_arm    = 4.5;   // [3:0.25:10]  drive pin, from its blade's pivot
pin_dir    = 140;   // [0:5:355]    pin direction at the open end
/* [Mount and lock] */
// tool axis on the rack's X - the base's -X edge has to clear the Z-rail
axis_x     = 33;    // [25:0.5:50]
axis_y     = -4.28; // [-12:0.1:4]
axis_z     = 13.15; // [5:0.1:40]  set so the tongue lands in the rack's slot
// A rubber band pulls the ring closed, so the iris grips on its own: twist the
// tab open against the band, drop the brush in, let go. No screw, no tool.
// The iris amplifies barrel load 13x (open) to 26x (closed) back into the ring,
// so ~7-15 N of band gives ~10 N per blade - about 12 N of axial hold.
// hook angles are chosen to land between the pivot posts and between the
// ring's drive slots - posts sit at iris_clock + 0/120/240
lock_ang   = 32;    // [0:1:355]   where the base's band hook sits
// the iris is clocked so the blade sweep leaves a gap at the back, letting the
// mounting face be flat and sit as close to the machine as possible
iris_clock = 92;    // [0:1:120]
// screw hole in the mounting tongue - clearance, so the screw pulls it tight
mount_hole = 3.4;   // [2.8:0.1:4.5]
// The tongue now reaches up into the ring's plane at the back, so the ring's
// tabs have to stay out of that rear sector as well as off the drive slots.
band_ang   = 255;   // [30:5:300]  ring hook, measured round from that hook
// finger tab: clear of both hooks and of the ring's drive slots
tab_ang    = 125;   // [0:5:355]
// teeth on the blades' gripping edges
tooth_p    = 1.3;   // [0.6:0.1:3]  pitch along the edge
tooth_d    = 0.40;  // [0.1:0.05:1] how deep they bite
// manual lever
lever_d    = 8.0;   // [5:0.5:14]   thumb boss diameter
lever_h    = 5.0;   // [2:0.5:10]   how far it stands above the ring
lever_w    = 9.0;   // [5:0.5:16]   paddle width
band_hook_r = 18;   // [12:0.5:24] radius of the hook on the ring
// A hook is a hole for the band with a slot running out to the edge: slip the
// band through the slot and it sits in the hole. Cut into the plate itself, so
// it is exactly as thick as that plate and stands no taller.
hook_id    = 5.2;   // [3:0.1:9]   hole the band sits in
hook_slot  = 2.4;   // [1.5:0.1:4] slot the band slips through
hook_wall  = 2.2;   // [1.2:0.1:4] material round the hole
// buttress that roots the mounting tongue into the base
gus_w      = 5.4;   // [4:0.2:14]  width across
gus_d      = 2.3;   // [1:0.1:4]   depth behind the flat face

/* [Build] */
blade_t    = 1.6;   // [1:0.1:4]
base_t     = 3.6;   // [1.6:0.1:8]  also the root depth of the mount rib
ring_t     = 3;     // [2:0.1:6]
post_d     = 3.0;   // [2:0.1:5]
pin_d      = 3.0;   // [2:0.1:5]
play       = 0.3;   // [0.15:0.05:0.6]
blade_gap  = 0.25;  // [0.1:0.05:0.6]
wall       = 1.6;   // [1.2:0.1:4]
quality    = 96;    // [24:8:160]

/* [Hidden] */
$fn = quality;
r_open  = bore_max/2 + bore_slack;
r_close = bore_min/2;
edge_off = Rp - r_open;                       // edge line, from its pivot
// blade angle for a given bore, and the resulting ring angle
function th_of_r(r) = acos((r + edge_off)/Rp);
function pinpos(th) = [Rp + pin_arm*cos(pin_dir + th), pin_arm*sin(pin_dir + th)];
function psi_of(th) = atan2(pinpos(th)[1], pinpos(th)[0]);
th_close = th_of_r(r_close);
psi_span = psi_of(0) - psi_of(th_close);
// the edge must reach the tangent point, which slides to (-edge_off, Rp*sin th)
edge_len = Rp*sin(th_close) + 2.5;
pin_rmin = min(norm(pinpos(0)), norm(pinpos(th_close)));
pin_rmax = max(norm(pinpos(0)), norm(pinpos(th_close)));
R_base   = Rp + post_d/2 + wall + 0.6;
R_ring   = pin_rmax + pin_d/2 + wall;
blade_R  = Rp + (post_d + 2*wall + 1.2)/2;      // blades' swept radius
// The ring covers the disc out to R_ring, so the base's hook has to sit past
// that, on a small lobe. The lobe is only base_t thick - it lies in the base
// plate's plane and stands no taller than it.
R_hook_base = R_base + 0.4;
R_hook_ring = R_ring + 0.7;                     // ...on a small tab past the ring's rim
slot_ang    = [for(i=[0:2]) (120*i + psi_of(0) + iris_clock) % 360];
lever_r     = R_ring + 4;                       // thumb boss centre
flat_r   = 16.3;                                // flat mounting face, from the axis
// mount rib: wide and deep at the plate, narrow where it passes the blades
arm_h    = 11.3;                         // tongue height, matches the rack slot
rib_w    = 11.0;  rib_d  = 2.3;          // at the bed
rib_w2   = 5.2;   rib_d2 = 1.6;          // where it passes the blades
rib_w3   = 3.6;   rib_d3 = 1.2;          // at the top
rib_h    = 8.3;                          // stops below the ring
blade_z  = [for (i=[0:2]) base_t + i*(blade_t + blade_gap)];
ring_z   = blade_z[2] + blade_t + 0.7;   // clears the tallest pivot stud
top_z    = ring_z + ring_t;

echo(str("iris: bore ", 2*r_open, " -> ", 2*r_close, " mm,  blades swing ",
         th_close, " deg,  ring turns ", psi_span, " deg"));
echo(str("  base dia ", 2*R_base, "  ring dia ", 2*R_ring, "  height ", top_z,
         "  edge len ", edge_len, "  pin R ", pin_rmin, "..", pin_rmax));

// ---- one blade; printed three times ------------------------------------
// Local frame: pivot at the origin, working edge is the straight line
// x = -edge_off, material to the right of it. Placing it is just rotate(th).
// One simple closed polygon, not a row of touching triangles: consecutive
// triangles share an edge exactly, and the union of those is not manifold - it
// silently fails to cut at all.
saw_n  = ceil((edge_len + 3)/tooth_p);
saw_y0 = -2;
function sawtooth() = concat(
  [[-edge_off - 1.5, saw_y0]],
  [ for (k = [0 : saw_n]) each [
      [-edge_off - 0.02,    saw_y0 + k*tooth_p],
      [-edge_off + tooth_d, saw_y0 + (k + 0.65)*tooth_p] ] ],
  [[-edge_off - 0.02, saw_y0 + (saw_n + 1)*tooth_p],
   [-edge_off - 1.5,  saw_y0 + (saw_n + 1)*tooth_p]]
);

module irisBlade(){
  p = [pin_arm*cos(pin_dir), pin_arm*sin(pin_dir)];
  difference(){
    union(){
      linear_extrude(blade_t)
        hull(){
          circle(d = post_d + 2*wall + 1.2);                    // pivot hub
          translate(p) circle(d = pin_d + 2*wall);              // pin boss
          translate([-edge_off + wall, 0])       circle(r = wall);
          translate([-edge_off + wall, edge_len]) circle(r = wall);
        }
      // drive pin, long enough to reach the ring from the lowest blade
      translate([p[0], p[1], 0]) cylinder(d = pin_d, h = top_z - blade_z[0] - 0.5);
    }
    translate([0,0,-1]) cylinder(d = post_d + play, h = blade_t + 2);
    // Sawtooth along the gripping edge. The tips are left exactly on the
    // design line x = -edge_off, so the three edges are still tangent to one
    // circle on the axis and the centring is untouched - only the valleys are
    // cut back, which is what lets the teeth bite instead of sliding.
    translate([0,0,-1]) linear_extrude(blade_t + 2) polygon(sawtooth());
  }
}

// ---- the base ----------------------------------------------------------
module irisBase(){
 union(){
  difference(){
    union(){
      cylinder(r = R_base, h = base_t);
      // No guide rim: the three drive pins in three radial slots already centre
      // the ring. The band hook is a hole cut in a flat lobe on the rim, in the
      // base plate's own plane - nothing stands proud of it.
      rotate([0,0,lock_ang]) hull(){
        translate([R_base - 4, 0, 0])  cylinder(r = 4, h = base_t);
        translate([R_hook_base, 0, 0]) cylinder(r = hook_id/2 + hook_wall, h = base_t);
      }
      // three pivot posts, each shouldered to its blade's height
      for (i = [0:2]) rotate([0,0,120*i + iris_clock]) translate([Rp, 0, 0]){
        if (blade_z[i] > base_t)
          cylinder(d = post_d + 2.2, h = blade_z[i]);
        cylinder(d = post_d, h = blade_z[i] + blade_t + 0.4);
      }
    }
    translate([0,0,-1]) cylinder(r = r_open + 0.6, h = base_t + 2);   // the bore
    // band hook, cut into the base plate
    rotate([0,0,lock_ang]) translate([R_hook_base, 0, -1])
      linear_extrude(base_t + 2) hookCut(hook_id/2 + hook_wall + 2);
    // flat mounting face at the back - it lands in the gap the clocking leaves
    translate([-flat_r - 60, -60, -60]) cube([60, 120, 120]);
  }
  mountRib();
  // the tongue has to cross that flat, so it is added after the cut
  irisArm();
 }
}

// ---- band hook: a hole with a slot out to the edge ----------------------
// Subtracted from a plate, so the hook lies in that plate's own plane and adds
// no height whatsoever. The slot runs radially outwards, well away from the
// direction the band pulls, so tension seats the band into the hole instead of
// dragging it back out through the slot.
module hookCut(reach = 12){
  circle(d = hook_id);
  translate([0, -hook_slot/2]) square([reach, hook_slot]);
}

// ---- rib that roots the tongue into the base ---------------------------
// Straight and tapered, not blobby. The base plate is the root; a single web
// carries the tongue up from it, thickest at the bottom where the bending
// moment is greatest and tapering as that moment falls off. It tapers inwards
// going up, so it prints with no overhang. Above the plate it is limited to the
// narrow gap the blades sweep past, and it stops short of the ring. Trimmed
// flush at the flat, so the mounting face stays flat.
module mountRib(){
  difference(){
    union(){
      // root, inside the plate's own thickness where no blade ever reaches:
      // this is the wide part of the load path
      hull(){
        translate([-flat_r, -rib_w/2, 0])              cube([rib_d, rib_w, 0.1]);
        translate([-flat_r, -rib_w/2, base_t - 0.1])   cube([rib_d, rib_w, 0.1]);
      }
      // web above it, held inside the gap the blades sweep past, tapering
      // inwards as it rises so it needs no support
      hull(){
        translate([-flat_r, -rib_w2/2, base_t])        cube([rib_d2, rib_w2, 0.1]);
        translate([-flat_r, -rib_w3/2, rib_h - 0.1])   cube([rib_d3, rib_w3, 0.1]);
      }
    }
    translate([-flat_r - 60, -60, -60]) cube([60, 120, 120]);
  }
}

// ---- mounting tongue: same interface the old penHolder used ------------
module irisArm(){
  difference(){
    union(){
      // Runs from the rack out to the flat face and no further; past that it
      // would be inside the blades' sweep. Built up from z=0 so the whole part
      // has one flat face on the bed.
      translate([8 - axis_x, -1.5, 0]) cube([(-flat_r) - (8 - axis_x), 3, arm_h]);
      translate([11.5 - axis_x, -2.5, arm_h/2]) rotate([90,0,0])
        cylinder(h = 2.4, d = 7, center = true);
    }
    translate([11.5 - axis_x, 10, arm_h/2]) rotate([90,0,0]) cylinder(20, d = mount_hole);
  }
}

// ---- the ring ----------------------------------------------------------
module irisRing(){
  difference(){
    union(){
      cylinder(r = R_ring, h = ring_t);
      // finger tab, and a tab over the ear carrying the lock slot
      // Manual lever: a rounded paddle with a raised thumb boss. Nothing
      // square to dig into a fingertip, and the boss gives something to push
      // sideways rather than pinching the ring's rim.
      rotate([0,0,tab_ang]){
        hull(){
          translate([R_ring - 3, 0, 0]) cylinder(r = 4.0,       h = ring_t);
          translate([lever_r,   0, 0])  cylinder(r = lever_w/2, h = ring_t);
        }
        translate([lever_r, 0, 0]){
          cylinder(d = lever_d, h = ring_t + lever_h);
          translate([0, 0, ring_t + lever_h])
            cylinder(d1 = lever_d, d2 = lever_d - 2.4, h = 1.2);   // eased top
        }
      }
      // tab carrying the ring's band hook
      rotate([0,0,lock_ang + band_ang]) hull(){
        translate([R_ring - 3, 0, 0])    cylinder(r = 3.2, h = ring_t);
        translate([R_hook_ring, 0, 0])   cylinder(r = hook_id/2 + hook_wall, h = ring_t);
      }
    }
    translate([0,0,-1]) cylinder(r = max(r_open + 1.2, pin_rmin - pin_d/2 - wall),
                                 h = ring_t + 2);
    // band hook, cut into that tab
    rotate([0,0,lock_ang + band_ang]) translate([R_hook_ring, 0, -1])
      linear_extrude(ring_t + 2) hookCut(hook_id/2 + hook_wall + 2);
    // three radial slots for the blades' drive pins
    for (i = [0:2]) rotate([0,0,120*i + psi_of(0) + iris_clock])
      translate([0,0,-1]) linear_extrude(ring_t + 2)
        hull(){
          translate([pin_rmin - 0.6, 0]) circle(d = pin_d + play);
          translate([pin_rmax + 0.6, 0]) circle(d = pin_d + play);
        }
  }
}

// ---- assembly ----------------------------------------------------------
module irisShow(bore = 8){
  th = th_of_r(bore/2);
  color("Khaki")   irisBase();
  for (i = [0:2]) rotate([0,0,120*i + iris_clock])
    color(["Tomato","Coral","Salmon"][i])
      translate([0,0,blade_z[i]]) translate([Rp,0,0]) rotate([0,0,th]) irisBlade();
  color("MediumSeaGreen")
    translate([0,0,ring_z]) rotate([0,0,psi_of(th) - psi_of(0)]) irisRing();
  color("SteelBlue",0.6) translate([0,0,-8]) cylinder(d = bore, h = 30);
}
translate([axis_x, axis_y, axis_z]) irisShow(13);
