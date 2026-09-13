// --- Parameters ---

/* [Generation] */
// Select what part you want to preview or export
part = "assembled"; // ["holder": Holder Bracket Only, "single_crucible": Single Crucible, "assembled": Full Assembly]

/* [Crucible (Color Pan) Dimensions] */
// How many color pans (slots) should the holder have?
num_pans = 5;         // [1:1:20]
// Width of the FIRST color pan (make it 30 for a larger pan on the left)
first_pan_w = 30;     // [5:0.1:50]
// Outer width of all the OTHER color pans (usually 19mm for half-pans)
pan_w = 19;           // [5:0.1:50]
// Outer length of the color pan (usually 30mm for half-pans)
pan_l = 30;           // [5:0.1:50]
// Total height of the crucible container
crucible_h = 10;       // [1:0.1:50]
// Wall thickness of the crucible. Inner volume shrinks based on this.
crucible_wall_t = 1.5; // [0.1:0.1:5.0]
// Rounding radius for the outside of the crucible (Set to 0 for a sharp rectangular block)
crucible_outer_r = 1.5; // [0:0.1:10.0]
// Rounding radius for the inside cavity (Makes it bowl-like and easier to wipe with a brush)
crucible_inner_r = 4.0; // [0:0.1:10.0]
// Enable staircase steps inside the crucible for wiping the brush
wipe_steps_enabled = false;
// Number of wipe steps
wipe_steps_count = 4; // [1:1:10]
// How much length of the crucible is taken up by the steps (0.4 = 40%)
wipe_steps_length_pct = 0.4; // [0.1:0.05:0.8]

/* [Holder Dimensions] */
// Length of the dividing fingers behind the front flange (controls the holder depth)
finger_l = 30;        // [5:1:100]
// Rounding radius for the holder's top and side edges
holder_r = 2.0;       // [0:0.1:10.0]
// Extra gap to add around the crucible so it easily slides in and out of the holder
clearance = 0.1;      // [0:0.1:3.0]
// Gap distance between each pan slot
gap = 3.2;            // [0:0.1:20.0]
// Height (thickness) of the main holder plate
holder_h = 3;         // [1:0.1:20.0]
// Thickness of the walls around the slots
wall_t = 1.5;         // [0.5:0.1:10.0]
// Generate U-shape slots (open at the far end) or enclosed pockets
is_open_end = true;   
// Generate a solid bottom floor under the slots to prevent pans from falling through
has_bottom = false;   
// Thickness of the bottom floor (if enabled)
bottom_t = 1.5;       // [0.5:0.1:10.0]

/* [Spring Fingers] */
// Enable springy fingers between the crucibles (hollows the fingers and adds holding bulbs)
spring_fingers = true;
// Length of the flexible part of the finger
spring_finger_l = 28; // [5:1:50]
// Length of the gripping bulge (smaller value makes it more localized in the center)
spring_bulb_l = 10;   // [2:1:50]
// Width of the hollow slit cut into the fingers
spring_slit_w = 1.0;  // [0.2:0.1:5.0]
// Radius of the gripping bulbs protruding into the slots
spring_bulb_r = 0.5;  // [0.1:0.1:2.0]

/* [Labels] */
// Text labels to cut into the front flange for each slot
labels = ["W", "C", "M", "Y", "K"]; 
// Depth of the engraved text cut into the plastic
label_depth = 0.6;    // [0.2:0.1:2.0]
// Font size of the labels
label_size = 6;       // [2:1:20]

/* [Mounting & Flanges] */
// Length of the front solid flange area (perfect place to stick labels or text)
flange_l = 8;         // [5:1:50]
// Width of the solid area on the far left and right ends (used for mounting holes)
side_flange = 6;      // [0:1:50]
// Diameter of the screw mounting holes
mount_hole_d = 3;     // [1:0.1:10.0]
// Y-axis distance from the very front edge to the center of the mounting holes
mount_hole_y_offset = 4; // [1:0.1:20.0]

/* [Hidden] */

// --- Calculated variables ---
// The holder's outer dimensions and the center-to-center pitch of the pans
// are fixed and independent of clearance. Clearance only enlarges the subtracted slots.

function get_pan_w(i) = (i == 0) ? first_pan_w : pan_w;
function get_pan_x(i) = side_flange + (i == 0 ? 0 : first_pan_w + gap + (i - 1) * (pan_w + gap));

// Calculate total width using the first pan + all remaining pans
tot_w = (2 * side_flange) + first_pan_w + (num_pans > 1 ? (num_pans - 1) * (pan_w + gap) : 0);
front_wall = wall_t;
back_wall = is_open_end ? 0 : wall_t;
tot_l = flange_l + front_wall + finger_l + back_wall;
tot_h = has_bottom ? holder_h + bottom_t : holder_h;

module top_rounded_box(w, l, h, r) {
    if (r <= 0.001) {
        cube([w, l, h]);
    } else {
        safe_r = min(r, min(w/2 - 0.001, l/2 - 0.001));
        
        intersection() {
            hull() {
                // Top corners (spheres)
                translate([safe_r, safe_r, h - safe_r]) sphere(r=safe_r);
                translate([w-safe_r, safe_r, h - safe_r]) sphere(r=safe_r);
                translate([safe_r, l-safe_r, h - safe_r]) sphere(r=safe_r);
                translate([w-safe_r, l-safe_r, h - safe_r]) sphere(r=safe_r);
                
                // Bottom corners (thick cylinders to prevent CGAL issues)
                translate([safe_r, safe_r, 0]) cylinder(r=safe_r, h=safe_r);
                translate([w-safe_r, safe_r, 0]) cylinder(r=safe_r, h=safe_r);
                translate([safe_r, l-safe_r, 0]) cylinder(r=safe_r, h=safe_r);
                translate([w-safe_r, l-safe_r, 0]) cylinder(r=safe_r, h=safe_r);
            }
            cube([w, l, h]);
        }
    }
}

module petri_holder() {
    $fn = 32;
    union() {
        difference() {
            // Main body
            top_rounded_box(tot_w, tot_l, tot_h, holder_r);
            
            // Subtract pan slots (enlarged by clearance)
            for (i = [0 : num_pans - 1]) {
                pw = get_pan_w(i);
                
                // Crucible nominal base position
                cx = get_pan_x(i);
                cy = flange_l + front_wall;
                
                // Slot geometry
                slot_x = cx - clearance;
                slot_y = cy - clearance;
                slot_w = pw + 2 * clearance;
                // If open end, cut past the back of the block. Otherwise, add clearance at the back.
                y_cut_len = pan_l + 2 * clearance + (is_open_end ? 2 : 0);
                
                z_pos = has_bottom ? bottom_t : -1;
                z_cut_h = has_bottom ? holder_h + 1 : tot_h + 2;
                
                translate([slot_x, slot_y, z_pos])
                    cube([slot_w, y_cut_len, z_cut_h]);
            }
            
            // Subtract hollow slits for spring fingers
            if (spring_fingers) {
                // Inner slits between pans
                if (num_pans > 1) {
                    for (i = [0 : num_pans - 2]) {
                        cx_slit = get_pan_x(i) + get_pan_w(i) + clearance + (gap - 2 * clearance) / 2 - spring_slit_w / 2;
                        slit_l = spring_finger_l;
                        cy_slit = flange_l + front_wall + finger_l / 2 - slit_l / 2;
                        
                        // Cut a capsule-shaped slit to avoid sharp corners that can snap
                        hull() {
                            translate([cx_slit + spring_slit_w/2, cy_slit + spring_slit_w/2, -1])
                                cylinder(r=spring_slit_w/2, h=tot_h + 2);
                            translate([cx_slit + spring_slit_w/2, cy_slit + slit_l - spring_slit_w/2, -1])
                                cylinder(r=spring_slit_w/2, h=tot_h + 2);
                        }
                    }
                }
                
                // Outer slits in the side flanges
                inner_arm_w = (gap - 2 * clearance - spring_slit_w) / 2;
                slit_l = spring_finger_l;
                cy_slit = flange_l + front_wall + finger_l / 2 - slit_l / 2;
                
                // Left flange slit
                left_outer_cx_slit = get_pan_x(0) - clearance - inner_arm_w - spring_slit_w;
                hull() {
                    translate([left_outer_cx_slit + spring_slit_w/2, cy_slit + spring_slit_w/2, -1])
                        cylinder(r=spring_slit_w/2, h=tot_h + 2);
                    translate([left_outer_cx_slit + spring_slit_w/2, cy_slit + slit_l - spring_slit_w/2, -1])
                        cylinder(r=spring_slit_w/2, h=tot_h + 2);
                }
                
                // Right flange slit
                last = num_pans - 1;
                right_outer_cx_slit = get_pan_x(last) + get_pan_w(last) + clearance + inner_arm_w;
                hull() {
                    translate([right_outer_cx_slit + spring_slit_w/2, cy_slit + spring_slit_w/2, -1])
                        cylinder(r=spring_slit_w/2, h=tot_h + 2);
                    translate([right_outer_cx_slit + spring_slit_w/2, cy_slit + slit_l - spring_slit_w/2, -1])
                        cylinder(r=spring_slit_w/2, h=tot_h + 2);
                }
            }
            
            // Mounting holes
            // First hole at left flange
            translate([side_flange / 2, mount_hole_y_offset, -1])
                cylinder(h = tot_h + 2, d = mount_hole_d);
                
            // Holes between slots
            if (num_pans > 1) {
                for (i = [0 : num_pans - 2]) {
                    // Gap is directly after crucible i
                    cx_gap = get_pan_x(i) + get_pan_w(i) + gap / 2;
                    translate([cx_gap, mount_hole_y_offset, -1])
                        cylinder(h = tot_h + 2, d = mount_hole_d);
                }
            }
            
            // Last hole at right flange
            translate([tot_w - side_flange / 2, mount_hole_y_offset, -1])
                cylinder(h = tot_h + 2, d = mount_hole_d);
                
            // Engrave Labels
            for (i = [0 : num_pans - 1]) {
                pw = get_pan_w(i);
                cx = get_pan_x(i) + pw / 2;
                cy = flange_l / 2;
                
                // Get the label for this slot, fallback to slot number if array is too short
                lbl = (i < len(labels)) ? labels[i] : str(i + 1);
                
                // Cut into the top surface of the holder
                translate([cx, cy, tot_h - label_depth])
                    linear_extrude(height = label_depth + 1)
                    text(text = lbl, size = label_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
            }
        }
        
        // Add bowed spring bulges into the slots
        if (spring_fingers) {
            safe_bulb_r = min(spring_bulb_r, (gap - 2 * clearance - spring_slit_w) / 2 * 0.99);
            bulb_y = flange_l + front_wall + finger_l / 2;
            bulb_z = has_bottom ? bottom_t : 0;
            bulb_h = holder_h;
            
            // Inner bulges
            if (num_pans > 1) {
                for (i = [0 : num_pans - 2]) {
                    // Left face of the finger (protruding into slot i)
                    left_bulb_x = get_pan_x(i) + get_pan_w(i) + clearance;
                    // Right face of the finger (protruding into slot i+1)
                    right_bulb_x = get_pan_x(i+1) - clearance;
                    
                    // Elliptical bulges localized in the middle of the finger
                    translate([left_bulb_x, bulb_y, bulb_z])
                        scale([safe_bulb_r, spring_bulb_l / 2, 1])
                        cylinder(h=bulb_h, r=1);
                    
                    translate([right_bulb_x, bulb_y, bulb_z])
                        scale([safe_bulb_r, spring_bulb_l / 2, 1])
                        cylinder(h=bulb_h, r=1);
                }
            }
            
            // Outer bulges
            // Protruding into the first slot from the left flange
            outer_left_bulb_x = get_pan_x(0) - clearance;
            translate([outer_left_bulb_x, bulb_y, bulb_z])
                scale([safe_bulb_r, spring_bulb_l / 2, 1])
                cylinder(h=bulb_h, r=1);
                
            // Protruding into the last slot from the right flange
            last = num_pans - 1;
            outer_right_bulb_x = get_pan_x(last) + get_pan_w(last) + clearance;
            translate([outer_right_bulb_x, bulb_y, bulb_z])
                scale([safe_bulb_r, spring_bulb_l / 2, 1])
                cylinder(h=bulb_h, r=1);
        }
    }
}

module simple_rounded_box(w, l, h, r) {
    if (r <= 0.001) {
        cube([w, l, h]);
    } else {
        // Safe radius to prevent geometry collapsing in on itself
        safe_r = min(r, min(w/2 - 0.001, l/2 - 0.001));
        
        intersection() {
            hull() {
                // Bottom corners (spheres)
                translate([safe_r, safe_r, safe_r]) sphere(r=safe_r);
                translate([w-safe_r, safe_r, safe_r]) sphere(r=safe_r);
                translate([safe_r, l-safe_r, safe_r]) sphere(r=safe_r);
                translate([w-safe_r, l-safe_r, safe_r]) sphere(r=safe_r);
                
                // Top corners (thick cylinders, preventing CGAL crashes)
                // Positioned at Z=h so the vertical walls are perfectly straight.
                translate([safe_r, safe_r, h]) cylinder(r=safe_r, h=safe_r);
                translate([w-safe_r, safe_r, h]) cylinder(r=safe_r, h=safe_r);
                translate([safe_r, l-safe_r, h]) cylinder(r=safe_r, h=safe_r);
                translate([w-safe_r, l-safe_r, h]) cylinder(r=safe_r, h=safe_r);
            }
            // Cut off the excess top cylinders to leave a perfectly flat top exactly at Z=h
            cube([w, l, h]);
        }
    }
}

module crucible(w = pan_w) {
    $fn = 32;
    union() {
        difference() {
            // Outer box
            simple_rounded_box(w, pan_l, crucible_h, crucible_outer_r);
            
            // Inner cavity
            translate([crucible_wall_t, crucible_wall_t, crucible_wall_t])
                simple_rounded_box(w - 2 * crucible_wall_t, pan_l - 2 * crucible_wall_t, crucible_h + 1, crucible_inner_r);
        }
        
        // Add wiping steps inside the cavity
        if (wipe_steps_enabled) {
            intersection() {
                // The intersection bounds the steps perfectly to the rounded inner walls
                translate([crucible_wall_t, crucible_wall_t, crucible_wall_t])
                    simple_rounded_box(w - 2 * crucible_wall_t, pan_l - 2 * crucible_wall_t, crucible_h + 1, crucible_inner_r);
                
                // The steps geometry (rising towards the back Y wall)
                step_area_l = pan_l * wipe_steps_length_pct;
                step_l = step_area_l / wipe_steps_count;
                max_step_z = crucible_h - crucible_wall_t;
                step_h = max_step_z / wipe_steps_count;
                
                for (i = [0 : wipe_steps_count - 1]) {
                    // Extend X safely beyond w to ensure intersection cuts it precisely
                    translate([-1, pan_l - step_area_l + i * step_l, crucible_wall_t])
                        cube([w + 2, step_l + 0.1, (i + 1) * step_h]); // +0.1 prevents co-planar rendering glitches
                }
            }
        }
    }
}

// --- Render ---
if (part == "holder" || part == "assembled") {
    translate([-30,0,0]) petri_holder();
}

if (part == "single_crucible") {
    // Generate both sizes of crucibles for easy printing
    crucible(first_pan_w);
    if (first_pan_w != pan_w) {
        translate([first_pan_w + 10, 0, 0]) crucible(pan_w);
    }
}

if (part == "assembled") {
    for (i = [0 : num_pans - 1]) {
        pw = get_pan_w(i);
        cx = get_pan_x(i);
        cy = flange_l + front_wall;
        z_pos = has_bottom ? bottom_t : 0;
        
        translate([cx, cy, z_pos])
            translate([-30,0,0]) crucible(pw);
    }
}
