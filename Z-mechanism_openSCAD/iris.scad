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
axis_z     = 18.5;  // [5:0.1:40]
// A rubber band pulls the ring closed, so the iris grips on its own: twist the
// tab open against the band, drop the brush in, let go. No screw, no tool.
// The iris amplifies barrel load 13x (open) to 26x (closed) back into the ring,
// so ~7-15 N of band gives ~10 N per blade - about 12 N of axial hold.
lock_ang   = 0;     // [0:5:355]   where the base's band hook sits (front)
// the iris is clocked so the blade sweep leaves a gap at the back, letting the
// mounting face be flat and sit as close to the machine as possible
iris_clock = 92;    // [0:1:120]
// screw hole in the mounting tongue - clearance, so the screw pulls it tight
mount_hole = 3.4;   // [2.8:0.1:4.5]
band_ang   = 75;    // [30:5:150]  ring hook, measured round from that post
band_hook_r = 18;   // [12:0.5:24] radius of the hook on the ring
hook_ro    = 4.8;   // [3:0.1:8]   hook outer radius
hook_wall  = 2.0;   // [1.2:0.1:3] hook thickness
hook_mouth = 95;    // [50:5:140]  how far the hook is open, deg
// buttress that roots the mounting tongue into the base
gus_w      = 5.4;   // [4:0.2:14]  width across
gus_d      = 2.3;   // [1:0.1:4]   depth behind the flat face

/* [Build] */
blade_t    = 1.6;   // [1:0.1:4]
base_t     = 2.6;   // [1.6:0.1:5]
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
R_ear    = blade_R + hook_ro + 0.8;             // band hook, clear of that
flat_r   = 16.3;                                // flat mounting face, from the axis
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
  }
}

// ---- the base ----------------------------------------------------------
module irisBase(){
 union(){
  difference(){
    union(){
      cylinder(r = R_base, h = base_t);
      // No guide rim: the three drive pins sitting in three radial slots
      // already centre the ring, and a rim would foul the blade hubs.
      // Local ear instead, carrying the lock screw.
      rotate([0,0,lock_ang]){
        // web at base level only - under the blades
        hull(){ translate([R_base - 4, 0, 0]) cylinder(r = 4, h = base_t);
                translate([R_ear, 0, 0])      cylinder(r = 3.5, h = base_t); }
        // band hook, standing clear of the blades' swept radius
        translate([R_ear, 0, 0]) bandHook(-44, base_t);
      }
      // three pivot posts, each shouldered to its blade's height
      for (i = [0:2]) rotate([0,0,120*i + iris_clock]) translate([Rp, 0, 0]){
        if (blade_z[i] > base_t)
          cylinder(d = post_d + 2.2, h = blade_z[i]);
        cylinder(d = post_d, h = blade_z[i] + blade_t + 0.4);
      }
    }
    translate([0,0,-1]) cylinder(r = r_open + 0.6, h = base_t + 2);   // the bore
    // flat mounting face at the back - it lands in the gap the clocking leaves
    translate([-flat_r - 60, -60, -60]) cube([60, 120, 120]);
  }
  mountBrace();
  // the tongue has to cross that flat, so it is added after the cut
  translate([0, 0, base_t/2]) irisArm();
 }
}

// ---- plain open hook: stretch the band and slip it straight on -----------
// The mouth faces away from the pull, so tension pulls the band into the crook
// rather than out of it, and a barb on the tip stops it walking off. Drawn in
// plan and extruded, so it prints with no overhang at all.
module bandHook(face = 0, h = 3){
  linear_extrude(h)
    union(){
      difference(){
        circle(r = hook_ro);
        circle(r = hook_ro - hook_wall);
        rotate(face - hook_mouth/2)
          polygon([[0,0], [3*hook_ro, 0],
                   [3*hook_ro*cos(hook_mouth), 3*hook_ro*sin(hook_mouth)]]);
      }
      rotate(face + hook_mouth/2) translate([hook_ro - hook_wall/2, 0])
        circle(d = hook_wall*1.4);       // barb on the tip
    }
}

// ---- brace that roots the tongue into the base -------------------------
// Grown rather than bolted on: a trunk running up the flat face, thickest low
// down where the bending moment is, then roots fanning out underneath the base
// disc where there is open space. Load spreads into the disc over a wide arc
// instead of stopping at one 2.6 mm edge. Everything is trimmed off flush at
// the flat, so the mounting face stays flat.
// The trunk is squeezed into the narrow band the blades leave behind the flat;
// the roots sit below the disc, where they can be as fat as they like.
module mountBrace(){
  difference(){
    union(){
      // trunk: full height of the tongue, tapering as it rises
      hull(){
        translate([-flat_r + 1.15, 0, -4.1]) scale([1, 2.3, 1]) sphere(r = 1.15);
        translate([-flat_r + 1.15, 0,  2.2]) scale([1, 2.3, 1]) sphere(r = 1.15);
      }
      hull(){
        translate([-flat_r + 1.15, 0,  2.2]) scale([1, 2.3, 1]) sphere(r = 1.15);
        translate([-flat_r + 1.10, 0,  8.0]) scale([1, 1.5, 1]) sphere(r = 1.00);
      }
      // roots, fanning out under the disc
      for (s = [-1, 1]){
        hull(){ translate([-flat_r + 1.5, s*0.9, -2.8]) sphere(r = 1.6);
                translate([-11.0, s*7.5, -0.9]) sphere(r = 1.35); }
        hull(){ translate([-flat_r + 1.5, s*0.9, -2.0]) sphere(r = 1.5);
                translate([ -6.0, s*11.0, -0.8]) sphere(r = 1.10); }
        hull(){ translate([-flat_r + 1.5, s*0.9, -1.2]) sphere(r = 1.4);
                translate([-13.8, s*3.8, -0.7]) sphere(r = 1.20); }
      }
    }
    translate([-flat_r - 60, -60, -60]) cube([60, 120, 120]);   // keep the back flat
  }
}

// ---- mounting tongue: same interface the old penHolder used ------------
module irisArm(){
  difference(){
    union(){
      // runs from the rack out to the flat face, and no further - past that it
      // would be inside the blades' sweep
      translate([8 - axis_x, -1.5, -5.65]) cube([(-flat_r) - (8 - axis_x), 3, 11.3]);
      translate([11.5 - axis_x, -2.5, 0]) rotate([90,0,0])
        cylinder(h = 2.4, d = 7, center = true);
    }
    translate([11.5 - axis_x, 10, 0]) rotate([90,0,0]) cylinder(20, d = mount_hole);
  }
}

// ---- the ring ----------------------------------------------------------
module irisRing(){
  difference(){
    union(){
      cylinder(r = R_ring, h = ring_t);
      // finger tab, and a tab over the ear carrying the lock slot
      rotate([0,0,60]) translate([R_ring - 2, -4, 0]) cube([10, 8, ring_t]);
      // band hook: the band runs from here to the post on the base
      rotate([0,0,lock_ang + band_ang]){
        hull(){
          translate([R_ring - 2, 0, 0])   cylinder(r = 3.0, h = ring_t);
          translate([band_hook_r, 0, 0])  cylinder(r = hook_ro, h = ring_t);
        }
        translate([band_hook_r, 0, 0]) bandHook(61, ring_t);
      }
    }
    translate([0,0,-1]) cylinder(r = max(r_open + 1.2, pin_rmin - pin_d/2 - wall),
                                 h = ring_t + 2);
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
