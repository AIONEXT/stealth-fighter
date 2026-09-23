include <config.scad>

module fuselage() {
    if (!show_fuselage) return;

    // Build fuselage using polyhedron sections for precise stealth shaping
    // Nose to tail construction with chine lines and area ruling
    
    $fn = resolution;
    
    // ============================================================
    // FUSELAGE CROSS-SECTION GENERATOR
    // ============================================================
    function fuse_section(x_pos) = 
        let(
            // Normalized position (0 = nose, 1 = tail)
            t = x_pos / fuse_length,
            
            // Width profile with area ruling
            width_base = t < 0.25 ? 
                nose_width_base + (fwd_fuse_width - nose_width_base) * (t / 0.25) :
            t < 0.5 ? 
                fwd_fuse_width + (mid_fuse_width * area_rule_waist - fwd_fuse_width) * ((t - 0.25) / 0.25) :
            t < 0.75 ?
                mid_fuse_width * area_rule_waist + (aft_fuse_width - mid_fuse_width * area_rule_waist) * ((t - 0.5) / 0.25) :
                aft_fuse_width,
            
            // Height profile
            height_base = t < 0.25 ?
                nose_height_base + (fwd_fuse_height - nose_height_base) * (t / 0.25) :
            t < 0.5 ?
                fwd_fuse_height + (mid_fuse_height - fwd_fuse_height) * ((t - 0.25) / 0.25) :
            t < 0.75 ?
                mid_fuse_height + (aft_fuse_height - mid_fuse_height) * ((t - 0.5) / 0.25) :
                aft_fuse_height,
            
            // Chine width (edge alignment)
            chine_width = t < 0.4 ?
                nose_width_base * 0.8 + (mid_fuse_chine_width - nose_width_base * 0.8) * (t / 0.4) :
            t < 0.8 ?
                mid_fuse_chine_width + (aft_fuse_width * 0.7 - mid_fuse_chine_width) * ((t - 0.4) / 0.4) :
                aft_fuse_width * 0.7,
            
            // Chine height
            chine_height = height_base * 0.65
        )
        [
            width_base, height_base, chine_width, chine_height
        ];

    // ============================================================
    // GENERATE FUSELAGE USING LOFT/HULL OF SECTIONS
    // ============================================================
    // Number of cross-sections for smooth lofting
    sections = 24;
    
    // Build the fuselage as a series of hulled cross-sections
    // Each section is a polygon representing the stealth cross-section
    
    for (i = [0 : sections - 2]) {
        let(
            x1 = -fuse_length/2 + (fuse_length / (sections - 1)) * i,
            x2 = -fuse_length/2 + (fuse_length / (sections - 1)) * (i + 1),
            s1 = fuse_section(x1 + fuse_length/2),
            s2 = fuse_section(x2 + fuse_length/2)
        ) {
            // Section 1 polygon
            // Points: top-center, top-chine, chine-corner, bottom-chine, bottom-center, bottom-chine-other, chine-corner-other, top-chine-other
            w1 = s1[0]; h1 = s1[1]; cw1 = s1[2]; ch1 = s1[3];
            w2 = s2[0]; h2 = s2[1]; cw2 = s2[2]; ch2 = s2[3];
            
            // Create stealth cross-section polygon
            // Top center -> top chine -> chine corner -> bottom chine -> bottom center (mirror)
            poly_section(x1, w1, h1, cw1, ch1, x2, w2, h2, cw2, ch2);
        }
    }
    
    // Nose cap
    translate([-fuse_length/2, 0, 0])
    rotate([0, 90, 0])
    cone_section(nose_length, 0, nose_width_base, nose_height_base);
    
    // Tail cap (exhaust integration area)
    translate([fuse_length/2, 0, 0])
    rotate([0, 90, 0])
    cone_section(aft_fuse_length, aft_fuse_width, aft_fuse_width * 0.6, aft_fuse_height);
}

// ============================================================
// HELPER: Create a lofted section between two cross-sections
// ============================================================
module poly_section(x1, w1, h1, cw1, ch1, x2, w2, h2, cw2, ch2) {
    // Stealth cross-section profile (half, mirrored)
    // Points going clockwise from top center
    angle_step = 180 / 16;
    
    // Generate points for section 1 (half)
    pts1 = [
        [0, h1],                              // Top center
        [cw1 * 0.3, ch1 + (h1 - ch1) * 0.7],  // Upper chine blend
        [cw1, ch1],                           // Chine corner
        [w1 * 0.7, ch1 * 0.3],                // Lower chine blend
        [w1, 0],                              // Max width at centerline
        [w1 * 0.7, -ch1 * 0.3],               // Lower chine blend (bottom)
        [cw1, -ch1],                          // Chine corner (bottom)
        [cw1 * 0.3, -ch1 - (h1 - ch1) * 0.7], // Upper chine blend (bottom)
        [0, -h1]                              // Bottom center
    ];
    
    // Generate points for section 2 (half)
    pts2 = [
        [0, h2],
        [cw2 * 0.3, ch2 + (h2 - ch2) * 0.7],
        [cw2, ch2],
        [w2 * 0.7, ch2 * 0.3],
        [w2, 0],
        [w2 * 0.7, -ch2 * 0.3],
        [cw2, -ch2],
        [cw2 * 0.3, -ch2 - (h2 - ch2) * 0.7],
        [0, -h2]
    ];
    
    // Mirror and create full polygons
    full_pts1 = concat(pts1, [for (p = reverse(pts1)) [-p[0], p[1]]]);
    full_pts2 = concat(pts2, [for (p = reverse(pts2)) [-p[0], p[1]]]);
    
    // Loft between sections using hull
    hull() {
        // Section 1
        translate([x1, 0, 0])
        linear_extrude(height = 0.01)
        polygon(full_pts1);
        
        // Section 2
        translate([x2, 0, 0])
        linear_extrude(height = 0.01)
        polygon(full_pts2);
    }
}

// ============================================================
// HELPER: Cone/rounded end cap
// ============================================================
module cone_section(length, tip_width, base_width, base_height) {
    // Create a tapered end using hull of polygons
    steps = 10;
    for (i = [0 : steps - 2]) {
        let(
            t1 = i / (steps - 1),
            t2 = (i + 1) / (steps - 1),
            w1 = tip_width + (base_width - tip_width) * t1,
            w2 = tip_width + (base_width - tip_width) * t2,
            h1 = 0 + (base_height - 0) * t1,
            h2 = 0 + (base_height - 0) * t2,
            x1 = -length + length * t1,
            x2 = -length + length * t2
        ) {
            hull() {
                translate([x1, 0, 0])
                linear_extrude(0.01)
                polygon([[0, h1], [w1, 0], [0, -h1], [-w1, 0]]);
                translate([x2, 0, 0])
                linear_extrude(0.01)
                polygon([[0, h2], [w2, 0], [0, -h2], [-w2, 0]]);
            }
        }
    }
}

// ============================================================
// INTAKE TRUNK INTEGRATION (internal ducting)
// ============================================================
module intake_trunks() {
    if (!show_intakes) return;
    
    // Internal duct representation (simplified)
    translate([-fuse_length/2 + fuse_length * intake_position, 0, 0])
    rotate([0, 90, 0]) {
        // Left intake trunk
        translate([0, intake_width/2 + 2, 0])
        loft_duct(intake_length, intake_height, intake_width, intake_height * 1.5, intake_width * 1.5);
        
        // Right intake trunk
        translate([0, -intake_width/2 - 2, 0])
        loft_duct(intake_length, intake_height, intake_width, intake_height * 1.5, intake_width * 1.5);
    }
}

// Simple duct lofting
module loft_duct(length, h1, w1, h2, w2) {
    steps = 8;
    for (i = [0 : steps - 2]) {
        let(
            t1 = i / (steps - 1),
            t2 = (i + 1) / (steps - 1),
            hh1 = h1 + (h2 - h1) * t1,
            hw1 = w1 + (w2 - w1) * t1,
            hh2 = h1 + (h2 - h1) * t2,
            hw2 = w1 + (w2 - w1) * t2,
            x1 = length * t1,
            x2 = length * t2
        ) {
            hull() {
                translate([x1, 0, 0])
                linear_extrude(0.01)
                polygon(round_rect_points(hw1, hh1));
                translate([x2, 0, 0])
                linear_extrude(0.01)
                polygon(round_rect_points(hw2, hh2));
            }
        }
    }
}

function round_rect_points(w, h, r = 2) = 
    let(n = 16)
    [for (i = [0 : n - 1]) 
        let(a = 360 * i / n)
        [w/2 * cos(a) * (abs(cos(a)) > 0.7 ? 1 : 0.5 + 0.5 * sin(a * 2)), 
         h/2 * sin(a) * (abs(sin(a)) > 0.7 ? 1 : 0.5 + 0.5 * cos(a * 2))]];

// ============================================================
// EXHAUST INTEGRATION
// ============================================================
module exhaust_integration() {
    if (!show_exhausts) return;
    
    // Aft fuselage shaping around nozzles
    translate([fuse_length/2 - aft_fuse_length, 0, 0]) {
        // Nozzle bays in fuselage
        for (side = [-1, 1]) {
            translate([0, side * exhaust_spacing/2, 0])
            difference() {
                // Bay cavity
                cube([aft_fuse_length, exhaust_nozzle_width + 4, exhaust_nozzle_height + 4], center=true);
                
                // Nozzle cutout (handled by exhaust module)
            }
        }
    }
}

// ============================================================
// WEAPON BAY CAVITIES
// ============================================================
module weapon_bay_cavities() {
    if (!show_bay_doors) return;
    
    translate([-fuse_length/2 + fuse_length * bay_position, 0, -bay_depth/2]) {
        // Main weapon bay cavity
        cube([bay_length, bay_width + 4, bay_depth + 2], center=true);
        
        // Internal structure ribs
        for (i = [1 : 3]) {
            translate([-bay_length/2 + bay_length * i / 4, 0, 0])
            cube([2, bay_width, bay_depth], center=true);
        }
    }
}

// ============================================================
// LANDING GEAR BAYS
// ============================================================
module gear_bays() {
    if (!show_landing_gear) return;
    
    // Nose gear bay
    translate([-fuse_length/2 + fuse_length * nose_gear_position, 0, -fuse_height_max/2])
    cube([nose_gear_strut_length + 10, 12, nose_gear_strut_length + 5], center=true);
    
    // Main gear bays (in wing roots / fuselage sides)
    translate([-fuse_length/2 + fuse_length * main_gear_position, 0, -fuse_height_max/2]) {
        for (side = [-1, 1]) {
            translate([0, side * (fuse_width_max/2 + 5), 0])
            rotate([0, 0, side * -5])
            cube([main_gear_strut_length + 8, 14, main_gear_strut_length + 5], center=true);
        }
    }
}

// ============================================================
// STEALTH EDGE TREATMENTS
// ============================================================
module stealth_edges() {
    if (!align_edges) return;
    
    // Add sawtooth/serrations to trailing edges, bay doors, etc.
    // This is applied as a post-process modifier
}

// ============================================================
// MAIN FUSELAGE ASSEMBLY
// ============================================================
module fuselage_assembly() {
    // Main fuselage body
    fuselage();
    
    // Internal cavities (subtracted in actual use, shown here for reference)
    // intake_trunks();
    // exhaust_integration();
    // weapon_bay_cavities();
    // gear_bays();
    
    // Chine highlights (visual indicator of edge alignment)
    if (align_edges) {
        chine_lines();
    }
}

module chine_lines() {
    // Visual chine lines for reference
    color("red", 0.3) {
        // Upper chine line
        hull() {
            translate([-fuse_length/2, 0, fuse_height_max/2 * 0.6])
            sphere(0.5);
            translate([fuse_length/2, 0, aft_fuse_height/2 * 0.6])
            sphere(0.5);
        }
        // Lower chine line
        hull() {
            translate([-fuse_length/2, 0, -fuse_height_max/2 * 0.6])
            sphere(0.5);
            translate([fuse_length/2, 0, -aft_fuse_height/2 * 0.6])
            sphere(0.5);
        }
    }
}

// Instantiate for preview (when not in assembly)
fuselage_assembly();