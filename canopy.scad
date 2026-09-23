include <config.scad>

module canopy() {
    if (!show_canopy) return;
    
    $fn = resolution;
    
    // Canopy position along fuselage
    canopy_x = -fuse_length/2 + fuse_length * canopy_position;
    canopy_z = fuse_height_max * 0.15 + fuse_height_max * 0.5;  // On top of fuselage
    
    translate([canopy_x, 0, canopy_z]) {
        if (canopy_frameless) {
            frameless_canopy();
        } else {
            framed_canopy();
        }
    }
}

// ============================================================
// FRAMELESS STEALTH CANOPY (Gold-coated appearance)
// ============================================================
module frameless_canopy() {
    // Canopy profile - smooth, continuous curvature for stealth
    // Based on F-22/F-35 style frameless canopy
    
    // Canopy dimensions
    c_len = canopy_length;
    c_w = canopy_width_max;
    c_h = canopy_height_max * canopy_bulge;
    
    // Build canopy as lofted sections
    canopy_sections = 12;
    
    for (i = [0 : canopy_sections - 2]) {
        let(
            x1 = c_len * i / (canopy_sections - 1),
            x2 = c_len * (i + 1) / (canopy_sections - 1),
            t1 = i / (canopy_sections - 1),
            t2 = (i + 1) / (canopy_sections - 1),
            
            // Width profile (max at ~30% back, then taper)
            w1 = canopy_width_profile(t1),
            w2 = canopy_width_profile(t2),
            
            // Height profile (max at ~40% back for pilot headroom)
            h1 = canopy_height_profile(t1),
            h2 = canopy_height_profile(t2),
            
            // Edge alignment angles for stealth
            edge_angle1 = canopy_edge_angle(t1),
            edge_angle2 = canopy_edge_angle(t2)
        ) {
            canopy_segment(x1, x2, w1, w2, h1, h2, edge_angle1, edge_angle2);
        }
    }
    
    // Canopy forward frame (minimal)
    if (!canopy_frameless || canopy_frame_thickness > 0) {
        forward_frame();
    }
    
    // Aft canopy fairing into spine
    aft_fairing();
    
    // Gold coating representation (visual)
    if (canopy_stealth_coating) {
        gold_coating_indicator();
    }
}

function canopy_width_profile(t) = 
    t < 0.15 ? canopy_width_max * 0.3 + canopy_width_max * 0.7 * (t / 0.15) :
    t < 0.45 ? canopy_width_max :
    t < 0.85 ? canopy_width_max * (1 - 0.6 * (t - 0.45) / 0.4) :
    canopy_width_max * 0.4 * (1 - (t - 0.85) / 0.15);

function canopy_height_profile(t) = 
    t < 0.1 ? canopy_height_max * 0.4 + canopy_height_max * 0.6 * (t / 0.1) :
    t < 0.5 ? canopy_height_max :
    t < 0.9 ? canopy_height_max * (1 - 0.7 * (t - 0.5) / 0.4) :
    canopy_height_max * 0.3 * (1 - (t - 0.9) / 0.1);

function canopy_edge_angle(t) =
    t < 0.3 ? 35 :  // Forward edge alignment
    t < 0.7 ? 25 :  // Mid section
    15;             // Aft edge alignment

module canopy_segment(x1, x2, w1, w2, h1, h2, edge1, edge2) {
    // Generate stealth cross-section (half, mirrored)
    pts1 = canopy_section_points(w1, h1, edge1);
    pts2 = canopy_section_points(w2, h2, edge2);
    
    // Convert to 3D
    pts1_3d = [for (p = pts1) [x1 + p[0], p[1], p[2]]];
    pts2_3d = [for (p = pts2) [x2 + p[0], p[1], p[2]]];
    
    // Loft
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_3d);
        linear_extrude(height = 0.01)
        polygon(pts2_3d);
    }
}

function canopy_section_points(half_width, height, edge_angle) = 
    let(
        // Stealth canopy cross-section with aligned edges
        // Top center -> upper edge -> max width -> lower edge -> bottom center
        n = 20,
        upper_curve = [for (i = [0 : n/2]) 
            let(a = 90 * i / (n/2),
                w = half_width * sin(a),
                h = height * cos(a) * (1 - 0.2 * sin(a * 2))  // Flatten top slightly
            )
            [w, h]
        ],
        lower_curve = [for (i = [n/2 : n]) 
            let(a = 90 * (i - n/2) / (n/2),
                w = half_width * cos(a) * (1 - 0.15 * sin(a)),  // Chine-like lower edge
                h = -height * 0.3 * sin(a)  // Lower surface less curved
            )
            [w, h]
        ],
        full_upper = concat(upper_curve, [for (p = reverse(upper_curve)) [-p[0], p[1]]]),
        full_lower = concat(lower_curve, [for (p = reverse(lower_curve)) [-p[0], p[1]]])
    )
    concat(full_upper, [for (p = reverse(full_lower)) [p[0], p[1]]]);

module forward_frame() {
    // Minimal forward frame (windshield arch)
    frame_h = canopy_height_max * 0.4;
    frame_w = canopy_width_max * 0.6;
    frame_thick = canopy_frame_thickness;
    
    translate([-frame_thick * 2, 0, 0])
    hull() {
        // Lower frame
        translate([0, 0, frame_h * 0.1])
        scale([frame_thick, frame_w, frame_h * 0.8])
        sphere(1);
        
        // Upper frame arch
        translate([0, 0, frame_h * 0.9])
        rotate([90, 0, 0])
        scale([frame_thick, frame_w * 0.8, frame_h * 0.5])
        sphere(1);
    }
}

module aft_fairing() {
    // Fairing from canopy aft edge into fuselage spine
    fairing_len = canopy_length * 0.15;
    fairing_w = canopy_width_max * 0.4;
    fairing_h = canopy_height_max * 0.3;
    
    translate([canopy_length - fairing_len * 0.5, 0, 0])
    hull() {
        translate([0, 0, 0])
        scale([fairing_len, fairing_w, fairing_h])
        sphere(1);
        
        translate([fairing_len * 0.8, 0, -fairing_h * 0.5])
        scale([fairing_len * 0.4, fairing_w * 0.5, fairing_h * 0.3])
        sphere(1);
    }
}

module gold_coating_indicator() {
    // Visual indicator of gold coating (thin layer on top)
    color("gold", 0.3) {
        translate([0, 0, canopy_height_max * canopy_bulge * 1.01])
        scale([canopy_length * 1.02, canopy_width_max * 1.02, 0.1])
        sphere(1);
    }
}

// ============================================================
// FRAMED CANOPY (Traditional)
// ============================================================
module framed_canopy() {
    // Traditional framed canopy with visible frames
    frame_thick = canopy_frame_thickness;
    
    // Main canopy shape
    hull() {
        // Front
        translate([0, 0, canopy_height_max * 0.3])
        scale([canopy_length * 0.3, canopy_width_max * 0.5, canopy_height_max * 0.6])
        sphere(1);
        
        // Middle (max width/height)
        translate([canopy_length * 0.3, 0, canopy_height_max * 0.5])
        scale([canopy_length * 0.4, canopy_width_max, canopy_height_max])
        sphere(1);
        
        // Rear
        translate([canopy_length * 0.7, 0, canopy_height_max * 0.4])
        scale([canopy_length * 0.3, canopy_width_max * 0.6, canopy_height_max * 0.5])
        sphere(1);
    }
    
    // Frames
    frame_positions = [0.15, 0.35, 0.55, 0.75];
    for (pos = frame_positions) {
        translate([canopy_length * pos, 0, 0])
        canopy_frame(pos);
    }
}

module canopy_frame(position) {
    // Frame cross-section
    frame_h = canopy_height_profile(position) * 2;
    frame_w = canopy_width_profile(position) * 2;
    
    // Frame as thin extrusion
    linear_extrude(height = frame_thick)
    polygon([
        [-frame_w/2, -frame_h/2],
        [frame_w/2, -frame_h/2],
        [frame_w/2, frame_h/2],
        [-frame_w/2, frame_h/2]
    ]);
}

// ============================================================
// CANOPY OPENING MECHANISM (for display)
// ============================================================
module canopy_open(angle = 45) {
    // Hinged canopy (for display with pilot visible)
    rotate([angle, 0, 0]) {
        frameless_canopy();
    }
    
    // Hinge mechanism
    translate([canopy_length * 0.05, 0, canopy_height_max * 0.3])
    rotate([0, 90, 0])
    cylinder(h = canopy_width_max * 0.6, r = 2, center=true);
}

// For standalone preview
canopy();