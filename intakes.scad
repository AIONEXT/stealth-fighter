include <config.scad>

module intakes() {
    if (!show_intakes) return;
    
    $fn = resolution;
    
    // Intake position along fuselage
    intake_x = -fuse_length/2 + fuse_length * intake_position;
    intake_y = fuse_width_max/2 + 2;  // Offset from fuselage side
    intake_z = 0;  // Centerline height
    
    if (intake_type == "dsi") {
        dsi_intakes();
    } else if (intake_type == "serpentine") {
        serpentine_intakes();
    } else {
        conventional_intakes();
    }
}

// ============================================================
// DSI (Diverterless Supersonic Inlet) - F-35 style
// ============================================================
module dsi_intakes() {
    for (side = [-1, 1]) {
        let(y_pos = side * intake_y) {
            translate([intake_x, y_pos, intake_z]) {
                dsi_intake(side);
            }
        }
    }
}

module dsi_intake(side) {
    // DSI bump (compression surface)
    dsi_bump();
    
    // Cowl / inlet lip
    dsi_cowl(side);
    
    // Internal duct (simplified)
    dsi_duct(side);
    
    // Bleed doors
    if (intake_bleed_doors) {
        dsi_bleed_doors(side);
    }
}

module dsi_bump() {
    // The distinctive DSI bump forward of the inlet
    // Shaped to divert boundary layer away from engine face
    
    bump_len = dsi_bump_length;
    bump_h = dsi_bump_height;
    bump_w = intake_width * 1.3;
    
    // Bump profile - curved compression surface
    bump_sections = 10;
    
    for (i = [0 : bump_sections - 2]) {
        let(
            x1 = -bump_len * 0.2 + bump_len * i / (bump_sections - 1),
            x2 = -bump_len * 0.2 + bump_len * (i + 1) / (bump_sections - 1),
            t1 = (i + 0.2 * (bump_sections - 1)) / (bump_sections - 1 + 0.2 * (bump_sections - 1)),
            t2 = (i + 1 + 0.2 * (bump_sections - 1)) / (bump_sections - 1 + 0.2 * (bump_sections - 1)),
            
            // Bump height profile
            h1 = bump_h * sin(t1 * 90) * (1 - 0.3 * t1),  // Peak then taper
            h2 = bump_h * sin(t2 * 90) * (1 - 0.3 * t2),
            
            // Bump width
            w1 = bump_w * (0.5 + 0.5 * sin(t1 * 90)),
            w2 = bump_w * (0.5 + 0.5 * sin(t2 * 90))
        ) {
            // Bump section
            hull() {
                translate([x1, 0, h1/2])
                scale([1, w1/bump_w, h1/bump_h])
                sphere(bump_w/2);
                
                translate([x2, 0, h2/2])
                scale([1, w2/bump_w, h2/bump_h])
                sphere(bump_w/2);
            }
        }
    }
    
    // Forward fairing into fuselage
    translate([-bump_len * 0.3, 0, 0])
    hull() {
        translate([0, 0, 0])
        scale([bump_len * 0.3, bump_w * 0.5, bump_h * 0.2])
        sphere(1);
        
        translate([bump_len * 0.1, 0, bump_h * 0.3])
        scale([bump_len * 0.2, bump_w * 0.7, bump_h * 0.5])
        sphere(1);
    }
}

module dsi_cowl(side) {
    // Inlet cowl lip - sharp for supersonic, rounded for subsonic
    cowl_len = intake_length * 0.3;
    cowl_h = intake_height;
    cowl_w = intake_width;
    lip_radius = 2 * global_scale;  // Sharp lip for stealth
    
    // Cowl outer surface
    cowl_sections = 8;
    
    for (i = [0 : cowl_sections - 2]) {
        let(
            x1 = cowl_len * i / (cowl_sections - 1),
            x2 = cowl_len * (i + 1) / (cowl_sections - 1),
            t1 = i / (cowl_sections - 1),
            t2 = (i + 1) / (cowl_sections - 1),
            
            // Cowl expands from bump to capture area
            h1 = cowl_h * (0.7 + 0.3 * t1),
            h2 = cowl_h * (0.7 + 0.3 * t2),
            w1 = cowl_w * (0.8 + 0.2 * t1),
            w2 = cowl_w * (0.8 + 0.2 * t2)
        ) {
            // Outer cowl surface
            hull() {
                translate([x1, 0, 0])
                dsi_cowl_section(w1, h1, side);
                
                translate([x2, 0, 0])
                dsi_cowl_section(w2, h2, side);
            }
        }
    }
    
    // Inlet lip (sharp edge)
    dsi_lip(side);
}

module dsi_cowl_section(half_w, half_h, side) {
    // DSI cowl cross-section - rectangular with rounded corners
    // Aligned with fuselage chine lines
    n = 16;
    pts = [for (i = [0 : n - 1]) 
        let(a = 360 * i / n,
            w = half_w * (abs(cos(a)) > 0.5 ? 1 : 0.7 + 0.3 * abs(cos(a * 2))),
            h = half_h * (abs(sin(a)) > 0.5 ? 1 : 0.7 + 0.3 * abs(sin(a * 2)))
        )
        [w * cos(a), h * sin(a)]
    ];
    
    linear_extrude(height = 0.01)
    polygon(pts);
}

module dsi_lip(side) {
    // Sharp inlet lip for stealth (edge alignment)
    lip_w = intake_width;
    lip_h = intake_height;
    lip_thick = 1.5 * global_scale;
    
    // Upper lip
    translate([0, 0, lip_h/2])
    scale([lip_thick, lip_w, 1])
    sphere(lip_h/2);
    
    // Lower lip
    translate([0, 0, -lip_h/2])
    scale([lip_thick, lip_w, 1])
    sphere(lip_h/2);
    
    // Side lips
    for (s = [-1, 1]) {
        translate([0, s * lip_w/2, 0])
        scale([lip_thick, 1, lip_h])
        sphere(lip_w/2);
    }
}

module dsi_duct(side) {
    // Internal duct from inlet to engine face
    // Simplified representation
    duct_len = intake_length;
    throat_h = intake_height * 0.7;
    throat_w = intake_width * 0.7;
    engine_face_h = intake_height * intake_duct_area_ratio * 0.7;
    engine_face_w = intake_width * intake_duct_area_ratio * 0.7;
    
    // Duct centerline curves downward and inward (S-duct)
    duct_sections = 12;
    
    for (i = [0 : duct_sections - 2]) {
        let(
            x1 = intake_length * 0.3 + duct_len * i / (duct_sections - 1),
            x2 = intake_length * 0.3 + duct_len * (i + 1) / (duct_sections - 1),
            t1 = i / (duct_sections - 1),
            t2 = (i + 1) / (duct_sections - 1),
            
            // Duct curves down and in
            y_offset1 = -intake_width * 0.3 * sin(t1 * 180),
            y_offset2 = -intake_width * 0.3 * sin(t2 * 180),
            z_offset1 = -intake_height * 0.2 * (1 - cos(t1 * 180)),
            z_offset2 = -intake_height * 0.2 * (1 - cos(t2 * 180)),
            
            // Area reduction
            h1 = throat_h + (engine_face_h - throat_h) * t1,
            h2 = throat_h + (engine_face_h - throat_h) * t2,
            w1 = throat_w + (engine_face_w - throat_w) * t1,
            w2 = throat_w + (engine_face_w - throat_w) * t2
        ) {
            // Duct section (hollow - would be subtracted in real model)
            color("gray", 0.3) {
                hull() {
                    translate([x1, y_offset1, z_offset1])
                    scale([1, w1/throat_w, h1/throat_h])
                    sphere(throat_w/2);
                    
                    translate([x2, y_offset2, z_offset2])
                    scale([1, w2/throat_w, h2/throat_h])
                    sphere(throat_w/2);
                }
            }
        }
    }
}

module dsi_bleed_doors(side) {
    // Boundary layer bleed doors on DSI bump
    door_count = 4;
    door_len = dsi_bump_length / door_count * 0.6;
    door_w = intake_width * 0.4;
    
    color("darkgray") {
        for (i = [0 : door_count - 1]) {
            let(x_pos = -dsi_bump_length * 0.1 + dsi_bump_length * (i + 0.5) / door_count) {
                translate([x_pos, 0, dsi_bump_height * 0.6])
                rotate([0, -10, 0])  // Angled for airflow
                cube([door_len, door_w, 2], center=true);
            }
        }
    }
}

// ============================================================
// SERPENTINE INTAKE (F-22 style S-duct)
// ============================================================
module serpentine_intakes() {
    for (side = [-1, 1]) {
        let(y_pos = side * intake_y) {
            translate([intake_x, y_pos, intake_z]) {
                serpentine_intake(side);
            }
        }
    }
}

module serpentine_intake(side) {
    // Serpentine duct with multiple bends
    // Hides engine face from radar
    
    // Inlet face
    serpentine_inlet_face(side);
    
    // S-duct bends
    serpentine_duct(side);
    
    // Engine face
    serpentine_engine_face(side);
}

module serpentine_inlet_face(side) {
    // Rectangular inlet with sharp edges
    face_w = intake_width;
    face_h = intake_height;
    face_thick = 3 * global_scale;
    
    // Inlet lip (sharp for stealth)
    translate([0, 0, 0])
    color("darkgray") {
        // Face frame
        hull() {
            translate([-face_thick/2, -face_w/2, -face_h/2])
            cube([face_thick, 2, face_h]);
            translate([-face_thick/2, face_w/2, -face_h/2])
            cube([face_thick, 2, face_h]);
        }
        
        // Top/bottom lips
        hull() {
            translate([-face_thick/2, -face_w/2, face_h/2])
            cube([face_thick, face_w, 2]);
            translate([-face_thick/2, -face_w/2, -face_h/2])
            cube([face_thick, face_w, 2]);
        }
    }
    
    // Inlet ramp (compression surface)
    translate([-face_thick, 0, 0])
    rotate([0, intake_ramp_angle, 0])
    color("darkgray") {
        cube([intake_length * 0.2, face_w, face_h * 0.3], center=true);
    }
}

module serpentine_duct(side) {
    // S-duct with multiple bends
    num_bends = intake_serpentine_bends;
    total_len = intake_length;
    bend_len = total_len / (num_bends + 1);
    
    duct_w = intake_width * 0.8;
    duct_h = intake_height * 0.8;
    
    current_x = 0;
    current_y = 0;
    current_z = 0;
    current_angle = 0;
    
    for (bend = [0 : num_bends]) {
        // Straight section
        straight_len = bend_len * 0.6;
        
        // Straight duct section
        for (i = [0 : 3]) {
            let(
                x1 = current_x + straight_len * i / 3,
                x2 = current_x + straight_len * (i + 1) / 3
            ) {
                hull() {
                    translate([x1, current_y, current_z])
                    scale([1, duct_w, duct_h])
                    sphere(1);
                    translate([x2, current_y, current_z])
                    scale([1, duct_w, duct_h])
                    sphere(1);
                }
            }
        }
        
        current_x += straight_len;
        
        // Bend (except after last straight section)
        if (bend < num_bends) {
            // Alternate bend direction (S-shape)
            bend_angle = (bend % 2 == 0) ? -45 : 45;  // Alternate up/down
            bend_radius = duct_h * 1.5;
            
            bend_sections = 8;
            for (i = [0 : bend_sections - 2]) {
                let(
                    a1 = bend_angle * i / (bend_sections - 1),
                    a2 = bend_angle * (i + 1) / (bend_sections - 1),
                    x1 = current_x + bend_radius * sin(a1),
                    x2 = current_x + bend_radius * sin(a2),
                    z1 = current_z + bend_radius * (1 - cos(a1)) * (bend_angle > 0 ? 1 : -1),
                    z2 = current_z + bend_radius * (1 - cos(a2)) * (bend_angle > 0 ? 1 : -1)
                ) {
                    hull() {
                        translate([x1, current_y, z1])
                        rotate([a1, 0, 0])
                        scale([1, duct_w, duct_h])
                        sphere(1);
                        translate([x2, current_y, z2])
                        rotate([a2, 0, 0])
                        scale([1, duct_w, duct_h])
                        sphere(1);
                    }
                }
            }
            
            current_x += bend_radius * sin(bend_angle);
            current_z += bend_radius * (1 - cos(bend_angle)) * (bend_angle > 0 ? 1 : -1);
            current_angle += bend_angle;
        }
    }
    
    // Final straight to engine
    final_len = total_len - current_x;
    for (i = [0 : 3]) {
        let(
            x1 = current_x + final_len * i / 3,
            x2 = current_x + final_len * (i + 1) / 3
        ) {
            hull() {
                translate([x1, current_y, current_z])
                scale([1, duct_w, duct_h])
                sphere(1);
                translate([x2, current_y, current_z])
                scale([1, duct_w, duct_h])
                sphere(1);
            }
        }
    }
}

module serpentine_engine_face(side) {
    // Engine compressor face (hidden by S-duct)
    face_w = intake_width * intake_duct_area_ratio;
    face_h = intake_height * intake_duct_area_ratio;
    
    color("darkgray", 0.5) {
        translate([intake_length, 0, 0])
        cylinder(h = 1, r = min(face_w, face_h)/2, center=true);
    }
}

// ============================================================
// CONVENTIONAL INTAKE (Simple)
// ============================================================
module conventional_intakes() {
    for (side = [-1, 1]) {
        translate([intake_x, side * intake_y, intake_z])
        rotate([0, 90, 0])
        cylinder(h = intake_length, r1 = intake_height/2, r2 = intake_height/2 * 0.7, center=true);
    }
}

// For standalone preview
intakes();