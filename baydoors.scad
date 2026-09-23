include <config.scad>

module bay_doors_closed() {
    if (!show_bay_doors) return;
    
    $fn = resolution;
    
    // Bay position along fuselage
    bay_x = -fuse_length/2 + fuse_length * bay_position;
    bay_z = -bay_depth/2;
    
    translate([bay_x, 0, bay_z]) {
        // Main weapon bay doors (closed)
        for (side = [-1, 1]) {
            weapon_bay_door(side, 0);  // 0 = closed
        }
        
        // Bay cavity (internal)
        weapon_bay_cavity();
        
        // Internal weapons
        if (show_weapons) {
            internal_weapons();
        }
        
        // Door actuators / hinges
        door_actuators();
    }
}

module bay_doors_open() {
    if (!show_bay_doors) return;
    
    $fn = resolution;
    
    bay_x = -fuse_length/2 + fuse_length * bay_position;
    bay_z = -bay_depth/2;
    
    translate([bay_x, 0, bay_z]) {
        // Main weapon bay doors (open)
        for (side = [-1, 1]) {
            weapon_bay_door(side, bay_door_angle);  // Open angle
        }
        
        // Bay cavity
        weapon_bay_cavity();
        
        // Internal weapons (visible when open)
        if (show_weapons) {
            internal_weapons();
            // Weapons deployed/extended
            deployed_weapons();
        }
        
        // Door actuators
        door_actuators();
    }
}

// ============================================================
// WEAPON BAY DOOR
// ============================================================
module weapon_bay_door(side, angle) {
    // Door dimensions
    door_len = bay_length;
    door_w = bay_width/2 - 1;  // Half width minus gap
    door_thick = bay_door_thickness;
    
    // Door position
    door_y = side * (bay_width/4 + 0.5);
    door_hinge_y = side * (bay_width/2 + 0.5);  // Hinge at outer edge
    
    // Chine-aligned door profile (stealth)
    if (bay_door_chine) {
        chine_aligned_door(side, angle, door_len, door_w, door_thick, door_y, door_hinge_y);
    } else {
        simple_door(side, angle, door_len, door_w, door_thick, door_y, door_hinge_y);
    }
}

module chine_aligned_door(side, angle, len, w, thick, y_pos, hinge_y) {
    // Door with chine edge alignment for stealth
    // Door edge aligns with fuselage chine line
    
    // Door rotates around hinge line
    rotate([0, side * angle, 0]) {
        translate([len/2, hinge_y + side * w/2, thick/2]) {
            // Door panel with chine profile
            color("darkgray") {
                // Main door panel
                hull() {
                    // Forward edge (aligned with fuselage chine)
                    translate([0, 0, 0])
                    scale([len, w, thick])
                    sphere(1);
                    
                    // Aft edge (aligned)
                    translate([0, 0, 0])
                    scale([len, w, thick])
                    sphere(1);
                }
                
                // Chine edge detail (sharp edge for stealth)
                chine_edge_detail(side, len, w, thick);
            }
            
            // Door seal / gap treatment
            if (ram_gap_treatment) {
                door_seal(side, len, w, thick);
            }
        }
    }
}

module chine_edge_detail(side, len, w, thick) {
    // Sharp chine edge on door
    // Forward chine
    translate([0, side * w/2, 0])
    rotate([0, side * 35, 0])  // Align with fuselage chine angle
    color("darkgray", 0.8) {
        linear_extrude(height = thick * 2)
        polygon([
            [-len/2, -ram_edge_treatment],
            [len/2, -ram_edge_treatment],
            [len/2, ram_edge_treatment],
            [-len/2, ram_edge_treatment]
        ]);
    }
}

module door_seal(side, len, w, thick) {
    // RAM gap treatment
    color("black", 0.5) {
        // Sawtooth seal
        for (i = [0 : len / sawtooth_wavelength]) {
            let(x_pos = -len/2 + i * sawtooth_wavelength) {
                translate([x_pos, side * w/2, 0])
                rotate([0, side * 45, 0])
                cube([sawtooth_wavelength, sawtooth_amplitude, thick], center=true);
            }
        }
    }
}

module simple_door(side, angle, len, w, thick, y_pos, hinge_y) {
    // Simple rectangular door
    rotate([0, side * angle, 0]) {
        translate([len/2, hinge_y + side * w/2, thick/2])
        color("darkgray") {
            cube([len, w, thick], center=true);
        }
    }
}

// ============================================================
// WEAPON BAY CAVITY
// ============================================================
module weapon_bay_cavity() {
    // Internal bay cavity
    color("gray", 0.2) {
        translate([bay_length/2, 0, bay_depth/2])
        cube([bay_length, bay_width + 2, bay_depth], center=true);
    }
    
    // Bay floor structure
    bay_floor_structure();
    
    // Bay ceiling (fuselage inner surface)
    bay_ceiling();
    
    // Side walls
    bay_side_walls();
    
    // Bulkheads / ribs
    bay_bulkheads();
}

module bay_floor_structure() {
    // Floor with weapon rail mounts
    floor_thick = 5 * global_scale;
    
    color("darkgray") {
        translate([bay_length/2, 0, -bay_depth/2 + floor_thick/2])
        cube([bay_length, bay_width, floor_thick], center=true);
    }
    
    // Weapon rail mounting points
    if (weapon_rail_type == "launcher") {
        launcher_rails();
    } else {
        ejector_rails();
    }
}

module bay_ceiling() {
    // Ceiling with hydraulic/electrical routing
    ceil_thick = 3 * global_scale;
    
    color("darkgray") {
        translate([bay_length/2, 0, bay_depth/2 - ceil_thick/2])
        cube([bay_length, bay_width, ceil_thick], center=true);
    }
    
    // Hydraulic lines
    color("blue", 0.3) {
        for (i = [0 : 2]) {
            let(y_pos = -bay_width/3 + i * bay_width/3) {
                translate([bay_length/2, y_pos, bay_depth/2 - ceil_thick])
                cylinder(h = bay_length, r = 1.5 * global_scale, center=true);
            }
        }
    }
}

module bay_side_walls() {
    // Side walls
    wall_thick = 3 * global_scale;
    
    color("darkgray") {
        for (side = [-1, 1]) {
            translate([bay_length/2, side * (bay_width/2 + wall_thick/2), 0])
            cube([bay_length, wall_thick, bay_depth], center=true);
        }
    }
    
    // Access panels
    access_panels();
}

module access_panels() {
    // Maintenance access panels on bay walls
    panel_count = 4;
    panel_w = bay_length / panel_count * 0.6;
    panel_h = bay_depth * 0.4;
    
    color("gray", 0.7) {
        for (side = [-1, 1]) {
            for (i = [0 : panel_count - 1]) {
                let(x_pos = -bay_length/2 + bay_length * (i + 0.5) / panel_count) {
                    translate([x_pos, side * (bay_width/2 + wall_thick/2 + 0.5), 0])
                    cube([panel_w, 1, panel_h], center=true);
                }
            }
        }
    }
}

module bay_bulkheads() {
    // Structural bulkheads
    bulkhead_count = 3;
    bulkhead_thick = 4 * global_scale;
    
    color("darkgray") {
        for (i = [1 : bulkhead_count]) {
            let(x_pos = -bay_length/2 + bay_length * i / (bulkhead_count + 1)) {
                translate([x_pos, 0, 0])
                cube([bulkhead_thick, bay_width, bay_depth], center=true);
                
                // Lightening holes
                for (j = [1 : 3]) {
                    let(y_pos = -bay_width/2 + bay_width * j / 4) {
                        translate([x_pos, y_pos, 0])
                        cylinder(h = bulkhead_thick + 2, r = bay_depth * 0.15, center=true);
                    }
                }
            }
        }
    }
}

// ============================================================
// WEAPON RAILS / LAUNCHERS
// ============================================================
module launcher_rails() {
    // LAU-129 or similar launcher rails
    rail_len = weapon_length * 1.1;
    rail_w = 4 * global_scale;
    rail_h = 6 * global_scale;
    
    // Two rails per bay (side by side)
    rail_spacing = weapon_diameter * 2.5;
    
    color("darkgray") {
        for (side = [-1, 1]) {
            for (rail = [-1, 1]) {
                let(y_pos = side * (bay_width/4 + rail * rail_spacing/2)) {
                    translate([bay_length/2, y_pos, -bay_depth/2 + 5 * global_scale + rail_h/2])
                    cube([rail_len, rail_w, rail_h], center=true);
                    
                    // Rail lugs (for missile attachment)
                    rail_lugs(y_pos);
                }
            }
        }
    }
}

module rail_lugs(y_pos) {
    // Missile attachment lugs on rail
    lug_count = 4;
    lug_spacing = weapon_length / (lug_count + 1);
    
    color("steelblue") {
        for (i = [1 : lug_count]) {
            let(x_pos = -weapon_length/2 + lug_spacing * i) {
                translate([x_pos, y_pos, -bay_depth/2 + 5 * global_scale + 8 * global_scale])
                cube([2 * global_scale, 6 * global_scale, 4 * global_scale], center=true);
            }
        }
    }
}

module ejector_rails() {
    // BRU-61 or similar ejector rack
    rack_w = 8 * global_scale;
    rack_h = 10 * global_scale;
    rack_len = weapon_length * 1.1;
    
    color("darkgray") {
        for (side = [-1, 1]) {
            let(y_pos = side * bay_width/4) {
                translate([bay_length/2, y_pos, -bay_depth/2 + 5 * global_scale + rack_h/2])
                cube([rack_len, rack_w, rack_h], center=true);
                
                // Ejector pistons
                ejector_pistons(y_pos);
            }
        }
    }
}

module ejector_pistons(y_pos) {
    // Ejector pistons for missile launch
    piston_count = 2;
    
    color("silver") {
        for (i = [0 : piston_count - 1]) {
            let(x_pos = -weapon_length/2 + weapon_length * (i + 0.5) / piston_count) {
                translate([x_pos, y_pos, -bay_depth/2 + 5 * global_scale + 12 * global_scale])
                cylinder(h = 15 * global_scale, r = 2 * global_scale, center=true);
            }
        }
    }
}

// ============================================================
// INTERNAL WEAPONS
// ============================================================
module internal_weapons() {
    // Weapons stored in bay (stowed position)
    weapons_per_bay = weapon_count / 2;
    
    for (side = [-1, 1]) {
        for (w = [0 : weapons_per_bay - 1]) {
            let(
                x_pos = bay_length/2 + (w - (weapons_per_bay - 1)/2) * (weapon_length + 5 * global_scale),
                y_pos = side * bay_width/4
            ) {
                translate([x_pos, y_pos, -bay_depth/2 + 8 * global_scale]) {
                    weapon_missile();
                }
            }
        }
    }
}

module deployed_weapons() {
    // Weapons extended/deployed from bay (for display)
    weapons_per_bay = weapon_count / 2;
    
    for (side = [-1, 1]) {
        for (w = [0 : weapons_per_bay - 1]) {
            let(
                x_pos = bay_length/2 + (w - (weapons_per_bay - 1)/2) * (weapon_length + 5 * global_scale),
                y_pos = side * (bay_width/2 + 10 * global_scale)  // Extended out of bay
            ) {
                translate([x_pos, y_pos, -bay_depth/2 + 8 * global_scale]) {
                    // Rotate for launch trajectory
                    rotate([0, side * -10, 0]) {
                        weapon_missile();
                    }
                }
            }
        }
    }
}

module weapon_missile() {
    // Air-to-air missile (AIM-120 AMRAAM style) or air-to-ground
    if (weapon_type == "aam" || weapon_type == "mixed") {
        aam_missile();
    } else {
        agm_missile();
    }
}

module aam_missile() {
    // AIM-120 AMRAAM style
    m_len = weapon_length;
    m_dia = weapon_diameter;
    
    color("gray", 0.9) {
        // Missile body
        hull() {
            // Nose
            translate([0, 0, m_dia/2])
            scale([m_len * 0.8, 1, 1])
            sphere(m_dia/2);
            
            // Body
            translate([m_len * 0.7, 0, 0])
            cylinder(h = m_len * 0.6, r = m_dia/2, center=true);
            
            // Tail
            translate([m_len, 0, 0])
            scale([m_len * 0.2, 1, 1])
            sphere(m_dia/2);
        }
    }
    
    // Fins
    missile_fins(m_len, m_dia);
    
    // Guidance section (nose)
    color("white", 0.8) {
        translate([-m_len * 0.3, 0, 0])
        scale([m_len * 0.3, 1, 1])
        sphere(m_dia/2 * 0.9);
    }
    
    // Warhead section
    color("yellow", 0.5) {
        translate([m_len * 0.1, 0, 0])
        cylinder(h = m_len * 0.3, r = m_dia/2 * 0.95, center=true);
    }
    
    // Rocket motor
    color("darkgray") {
        translate([m_len * 0.6, 0, 0])
        cylinder(h = m_len * 0.4, r = m_dia/2, center=true);
    }
}

module agm_missile() {
    // AGM-158 JASSM style (longer, different fins)
    m_len = weapon_length * 1.3;
    m_dia = weapon_diameter * 1.2;
    
    color("gray", 0.8) {
        // Body (more cylindrical)
        translate([0, 0, 0])
        cylinder(h = m_len, r = m_dia/2, center=true);
        
        // Nose cone
        translate([-m_len/2, 0, 0])
        scale([m_len * 0.3, 1, 1])
        sphere(m_dia/2);
        
        // Tail
        translate([m_len/2, 0, 0])
        scale([m_len * 0.1, 1, 1])
        sphere(m_dia/2);
    }
    
    // Folded wings (stowed)
    missile_folded_wings(m_len, m_dia);
    
    // Tail fins
    missile_fins(m_len, m_dia);
}

module missile_fins(m_len, m_dia) {
    // Cruciform fins (4 fins)
    fin_span = weapon_fin_span;
    fin_root_chord = weapon_fin_chord * 1.5;
    fin_tip_chord = weapon_fin_chord * 0.5;
    fin_thick = 1.5 * global_scale;
    
    color("gray", 0.7) {
        for (fin = [0 : 3]) {
            let(angle = fin * 90) {
                rotate([0, 0, angle])
                translate([m_len * 0.7, 0, 0]) {
                    // Fin as lofted airfoil
                    fin_section(fin_span, fin_root_chord, fin_tip_chord, fin_thick);
                }
            }
        }
    }
}

module fin_section(span, root_c, tip_c, thick) {
    fin_sections = 6;
    
    for (i = [0 : fin_sections - 2]) {
        let(
            y1 = span * i / (fin_sections - 1),
            y2 = span * (i + 1) / (fin_sections - 1),
            eta1 = i / (fin_sections - 1),
            eta2 = (i + 1) / (fin_sections - 1),
            chord1 = root_c - (root_c - tip_c) * eta1,
            chord2 = root_c - (root_c - tip_c) * eta2
        ) {
            // Simple flat fin
            hull() {
                translate([0, y1, 0])
                scale([chord1, 1, thick])
                sphere(1);
                translate([0, y2, 0])
                scale([chord2, 1, thick])
                sphere(1);
            }
        }
    }
}

module missile_folded_wings(m_len, m_dia) {
    // Folded wings for internal carriage
    wing_span_folded = weapon_fin_span * 0.3;
    wing_chord = weapon_fin_chord * 2;
    
    color("gray", 0.7) {
        for (side = [-1, 1]) {
            rotate([0, 0, side * 90])
            translate([m_len * 0.2, side * wing_span_folded/2, 0])
            scale([wing_chord, wing_span_folded, 1.5 * global_scale])
            sphere(1);
        }
    }
}

// ============================================================
// DOOR ACTUATORS / HINGES
// ============================================================
module door_actuators() {
    // Hydraulic/electric door actuators
    actuator_count = 4;  // Per door
    
    color("darkgray") {
        for (side = [-1, 1]) {
            for (i = [0 : actuator_count - 1]) {
                let(x_pos = -bay_length/2 + bay_length * (i + 0.5) / actuator_count) {
                    // Actuator cylinder
                    translate([x_pos, side * (bay_width/2 + 3 * global_scale), -bay_depth/2 + 3 * global_scale])
                    rotate([90, 0, 0])
                    cylinder(h = 10 * global_scale, r = 2 * global_scale, center=true);
                    
                    // Actuator rod
                    translate([x_pos, side * (bay_width/2 + 8 * global_scale), -bay_depth/2 + 3 * global_scale])
                    cylinder(h = 20 * global_scale, r = 1 * global_scale, center=true);
                }
            }
        }
    }
    
    // Hinge mechanism
    door_hinges();
}

module door_hinges() {
    // Door hinges at outer edge
    hinge_count = 3;
    
    color("steelblue") {
        for (side = [-1, 1]) {
            for (i = [0 : hinge_count - 1]) {
                let(x_pos = -bay_length/2 + bay_length * (i + 0.5) / hinge_count) {
                    translate([x_pos, side * (bay_width/2 + 1 * global_scale), 0])
                    rotate([0, 90, 0])
                    cylinder(h = 4 * global_scale, r = 3 * global_scale, center=true);
                    
                    // Hinge pin
                    color("silver") {
                        translate([x_pos, side * (bay_width/2 + 3 * global_scale), 0])
                        rotate([0, 90, 0])
                        cylinder(h = 8 * global_scale, r = 1 * global_scale, center=true);
                    }
                }
            }
        }
    }
}

// For standalone preview
bay_doors_closed();
