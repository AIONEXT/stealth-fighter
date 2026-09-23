include <config.scad>

module wings() {
    if (!show_wings) return;
    
    $fn = resolution;
    
    // ============================================================
    // WING GEOMETRY CALCULATIONS
    // ============================================================
    semi_span = wing_span / 2;
    
    // Taper ratio
    taper_ratio = wing_tip_chord / wing_root_chord;
    
    // Mean aerodynamic chord (MAC)
    mac = (2/3) * wing_root_chord * (1 + taper_ratio + taper_ratio^2) / (1 + taper_ratio);
    
    // Leading edge positions
    le_root_x = 0;  // Root LE at fuselage centerline (will be positioned later)
    le_tip_x = semi_span * tan(wing_sweep_le);
    
    // Trailing edge positions
    te_root_x = wing_root_chord;
    te_tip_x = le_tip_x + wing_tip_chord;
    
    // Wing area
    wing_area = semi_span * (wing_root_chord + wing_tip_chord);
    
    // Aspect ratio
    aspect_ratio = wing_span^2 / (2 * wing_area);
    
    // ============================================================
    // WING AIRFOIL SECTIONS
    // ============================================================
    function airfoil_points(chord, thickness_ratio, camber = 0, camber_pos = 0.4) = 
        let(n = 50,
            upper = [for (i = [0 : n]) 
                let(x = chord * i / n,
                    t = thickness_ratio * chord * 5 * (0.2969*sqrt(x/chord) - 0.1260*(x/chord) - 0.3516*(x/chord)^2 + 0.2843*(x/chord)^3 - 0.1015*(x/chord)^4),
                    c = camber * chord * (x/chord <= camber_pos ? 
                        2*(x/chord)/camber_pos - (x/chord)^2/camber_pos^2 :
                        2*(1-x/chord)/(1-camber_pos) - (1-x/chord)^2/(1-camber_pos)^2)
                )
                [x, t + c]
            ],
            lower = [for (i = [n-1 : 0]) 
                let(x = chord * i / n,
                    t = thickness_ratio * chord * 5 * (0.2969*sqrt(x/chord) - 0.1260*(x/chord) - 0.3516*(x/chord)^2 + 0.2843*(x/chord)^3 - 0.1015*(x/chord)^4),
                    c = camber * chord * (x/chord <= camber_pos ? 
                        2*(x/chord)/camber_pos - (x/chord)^2/camber_pos^2 :
                        2*(1-x/chord)/(1-camber_pos) - (1-x/chord)^2/(1-camber_pos)^2)
                )
                [x, -t + c]
            ])
        concat(upper, lower);
    
    // ============================================================
    // MAIN WING CONSTRUCTION
    // ============================================================
    // Build wing as lofted airfoil sections
    wing_sections = 16;
    
    for (i = [0 : wing_sections - 2]) {
        let(
            // Spanwise position
            y1 = semi_span * i / (wing_sections - 1),
            y2 = semi_span * (i + 1) / (wing_sections - 1),
            
            // Normalized span position (0 = root, 1 = tip)
            eta1 = i / (wing_sections - 1),
            eta2 = (i + 1) / (wing_sections - 1),
            
            // Local chord (linear taper)
            chord1 = wing_root_chord * (1 - eta1 * (1 - taper_ratio)),
            chord2 = wing_root_chord * (1 - eta2 * (1 - taper_ratio)),
            
            // Leading edge x position
            le_x1 = le_root_x + y1 * tan(wing_sweep_le),
            le_x2 = le_root_x + y2 * tan(wing_sweep_le),
            
            // Thickness distribution
            thick1 = wing_thickness_dist == "cosine" ?
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta1 * 90) :
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta1,
            thick2 = wing_thickness_dist == "cosine" ?
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta2 * 90) :
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta2,
            
            // Dihedral
            z1 = y1 * tan(wing_dihedral),
            z2 = y2 * tan(wing_dihedral),
            
            // Twist (washout)
            twist1 = wing_twist * eta1,
            twist2 = wing_twist * eta2
        ) {
            // Build wing segment using hull of airfoil sections
            wing_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, z1, z2, twist1, twist2);
        }
    }
    
    // Mirror for other side
    mirror([0, 1, 0]) {
        for (i = [0 : wing_sections - 2]) {
            let(
                y1 = semi_span * i / (wing_sections - 1),
                y2 = semi_span * (i + 1) / (wing_sections - 1),
                eta1 = i / (wing_sections - 1),
                eta2 = (i + 1) / (wing_sections - 1),
                chord1 = wing_root_chord * (1 - eta1 * (1 - taper_ratio)),
                chord2 = wing_root_chord * (1 - eta2 * (1 - taper_ratio)),
                le_x1 = le_root_x + y1 * tan(wing_sweep_le),
                le_x2 = le_root_x + y2 * tan(wing_sweep_le),
                thick1 = wing_thickness_dist == "cosine" ?
                    wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta1 * 90) :
                    wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta1,
                thick2 = wing_thickness_dist == "cosine" ?
                    wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta2 * 90) :
                    wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta2,
                z1 = y1 * tan(wing_dihedral),
                z2 = y2 * tan(wing_dihedral),
                twist1 = wing_twist * eta1,
                twist2 = wing_twist * eta2
            ) {
                wing_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, z1, z2, twist1, twist2);
            }
        }
    }
    
    // ============================================================
    // WING ROOT FAIRING / BLEND
    // ============================================================
    if (wing_root_blend > 0) {
        wing_root_fairing();
    }
    
    // ============================================================
    // CONTROL SURFACES
    // ============================================================
    if (show_control_surfaces) {
        control_surfaces();
    }
}

// ============================================================
// WING SEGMENT - Loft between two airfoil sections
// ============================================================
module wing_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, z1, z2, twist1, twist2) {
    // Airfoil points for each section
    pts1 = airfoil_points(chord1, thick1);
    pts2 = airfoil_points(chord2, thick2);
    
    // Transform points to 3D
    // Section 1
    pts1_3d = [for (p = pts1) 
        [le_x1 + p[0], y1, z1 + p[1]]];
    
    // Section 2
    pts2_3d = [for (p = pts2) 
        [le_x2 + p[0], y2, z2 + p[1]]];
    
    // Apply twist (rotate around quarter-chord point)
    qc1 = le_x1 + 0.25 * chord1;
    qc2 = le_x2 + 0.25 * chord2;
    
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2] - z1)
        [qc1 + dx * cos(twist1) - dz * sin(twist1), p[1], z1 + dx * sin(twist1) + dz * cos(twist1)]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2] - z2)
        [qc2 + dx * cos(twist2) - dz * sin(twist2), p[1], z2 + dx * sin(twist2) + dz * cos(twist2)]];
    
    // Loft using hull of polygons
    hull() {
        // Section 1
        translate([0, 0, 0])
        linear_extrude(height = 0.01)
        polygon(pts1_twisted);
        
        // Section 2
        translate([0, 0, 0])
        linear_extrude(height = 0.01)
        polygon(pts2_twisted);
    }
}

// ============================================================
// WING ROOT FAIRING - Blend wing into fuselage
// ============================================================
module wing_root_fairing() {
    // Fairing extends forward and aft of wing root
    fairing_length = wing_fairing_length;
    fairing_height = wing_root_chord * wing_thickness_root * 1.5;
    fairing_width = wing_root_blend;
    
    // Forward fairing
    translate([-fairing_length * 0.3, 0, 0])
    hull() {
        // Fuselage side profile at wing root
        translate([0, wing_root_blend, 0])
        scale([fairing_length * 0.6, 1, 1])
        sphere(fairing_height/2);
        
        // Wing root
        translate([wing_root_chord * 0.2, 0, 0])
        scale([fairing_length * 0.4, fairing_width, fairing_height])
        sphere(1);
    }
    
    // Aft fairing
    translate([wing_root_chord - fairing_length * 0.3, 0, 0])
    hull() {
        translate([0, wing_root_blend, 0])
        scale([fairing_length * 0.6, 1, 1])
        sphere(fairing_height/2);
        
        translate([-wing_root_chord * 0.2, 0, 0])
        scale([fairing_length * 0.4, fairing_width, fairing_height])
        sphere(1);
    }
    
    // Mirror for other side
    mirror([0, 1, 0]) {
        // Forward fairing
        translate([-fairing_length * 0.3, 0, 0])
        hull() {
            translate([0, wing_root_blend, 0])
            scale([fairing_length * 0.6, 1, 1])
            sphere(fairing_height/2);
            
            translate([wing_root_chord * 0.2, 0, 0])
            scale([fairing_length * 0.4, fairing_width, fairing_height])
            sphere(1);
        }
        
        // Aft fairing
        translate([wing_root_chord - fairing_length * 0.3, 0, 0])
        hull() {
            translate([0, wing_root_blend, 0])
            scale([fairing_length * 0.6, 1, 1])
            sphere(fairing_height/2);
            
            translate([-wing_root_chord * 0.2, 0, 0])
            scale([fairing_length * 0.4, fairing_width, fairing_height])
            sphere(1);
        }
    }
}

// ============================================================
// CONTROL SURFACES (Ailerons, Flaps)
// ============================================================
module control_surfaces() {
    // Ailerons (outboard)
    aileron_span = semi_span * wing_aileron_span_ratio;
    aileron_root_y = semi_span * (1 - wing_aileron_span_ratio);
    
    // Flaps (inboard)
    flap_span = semi_span * wing_flap_span_ratio;
    flap_root_y = wing_root_blend + 2;  // Start just outboard of fairing
    
    // Build ailerons (both sides)
    for (side = [-1, 1]) {
        let(deflection = side * aileron_deflection) {
            // Aileron
            build_control_surface(
                "aileron",
                flap_root_y + flap_span,  // Start at flap tip
                semi_span,                 // End at tip
                wing_aileron_chord_ratio,
                deflection,
                side
            );
            
            // Flap
            build_control_surface(
                "flap",
                flap_root_y,
                flap_root_y + flap_span,
                wing_flap_chord_ratio,
                flap_deflection,
                side
            );
        }
    }
}

module build_control_surface(name, y_start, y_end, chord_ratio, deflection, side) {
    // Number of sections for control surface
    cs_sections = 8;
    
    for (i = [0 : cs_sections - 2]) {
        let(
            eta1 = i / (cs_sections - 1),
            eta2 = (i + 1) / (cs_sections - 1),
            y1 = y_start + (y_end - y_start) * eta1,
            y2 = y_start + (y_end - y_start) * eta2,
            
            // Normalized span for wing geometry
            eta_wing1 = y1 / semi_span,
            eta_wing2 = y2 / semi_span,
            
            // Local chord
            chord1 = wing_root_chord * (1 - eta_wing1 * (1 - taper_ratio)),
            chord2 = wing_root_chord * (1 - eta_wing2 * (1 - taper_ratio)),
            
            // Leading edge position
            le_x1 = le_root_x + y1 * tan(wing_sweep_le),
            le_x2 = le_root_x + y2 * tan(wing_sweep_le),
            
            // Trailing edge position
            te_x1 = le_x1 + chord1,
            te_x2 = le_x2 + chord2,
            
            // Control surface hinge line (at chord_ratio from LE)
            hinge_x1 = le_x1 + chord1 * (1 - chord_ratio),
            hinge_x2 = le_x2 + chord2 * (1 - chord_ratio),
            
            // Thickness
            thick1 = wing_thickness_dist == "cosine" ?
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta_wing1 * 90) :
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta_wing1,
            thick2 = wing_thickness_dist == "cosine" ?
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * sin(eta_wing2 * 90) :
                wing_thickness_root - (wing_thickness_root - wing_thickness_tip) * eta_wing2,
            
            // Dihedral
            z1 = y1 * tan(wing_dihedral),
            z2 = y2 * tan(wing_dihedral),
            
            // Twist
            twist1 = wing_twist * eta_wing1,
            twist2 = wing_twist * eta_wing2
        ) {
            // Control surface segment
            cs_segment(hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, z1, z2, thick1, thick2, twist1, twist2, deflection, side);
        }
    }
}

module cs_segment(hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, z1, z2, thick1, thick2, twist1, twist2, deflection, side) {
    // Control surface chord
    cs_chord1 = te_x1 - hinge_x1;
    cs_chord2 = te_x2 - hinge_x2;
    
    // Simple flat plate airfoil for control surface
    cs_thick1 = thick1 * 0.5;  // Thinner than main wing
    cs_thick2 = thick2 * 0.5;
    
    // Airfoil points for control surface
    pts1 = airfoil_points(cs_chord1, cs_thick1 / cs_chord1);
    pts2 = airfoil_points(cs_chord2, cs_thick2 / cs_chord2);
    
    // Transform to 3D
    pts1_3d = [for (p = pts1) [hinge_x1 + p[0], y1, z1 + p[1]]];
    pts2_3d = [for (p = pts2) [hinge_x2 + p[0], y2, z2 + p[1]]];
    
    // Apply twist + deflection (rotate around hinge line)
    pts1_rotated = [for (p = pts1_3d)
        let(dx = p[0] - hinge_x1, dz = p[2] - z1)
        [hinge_x1 + dx * cos(twist1) - dz * sin(twist1), p[1], z1 + dx * sin(twist1) + dz * cos(twist1)]];
    
    // Apply additional deflection rotation
    pts1_deflected = [for (p = pts1_rotated)
        let(dx = p[0] - hinge_x1, dz = p[2] - z1)
        [hinge_x1 + dx * cos(deflection) - dz * sin(deflection), p[1], z1 + dx * sin(deflection) + dz * cos(deflection)]];
    
    pts2_rotated = [for (p = pts2_3d)
        let(dx = p[0] - hinge_x2, dz = p[2] - z2)
        [hinge_x2 + dx * cos(twist2) - dz * sin(twist2), p[1], z2 + dx * sin(twist2) + dz * cos(twist2)]];
    
    pts2_deflected = [for (p = pts2_rotated)
        let(dx = p[0] - hinge_x2, dz = p[2] - z2)
        [hinge_x2 + dx * cos(deflection) - dz * sin(deflection), p[1], z2 + dx * sin(deflection) + dz * cos(deflection)]];
    
    // Mirror for other side
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_deflected);
        linear_extrude(height = 0.01)
        polygon(pts2_deflected);
    }
    
    // Also create the gap/fairing between wing and control surface
    // (Simplified - just the surface itself for now)
}

// ============================================================
// WING TIP DETAILS
// ============================================================
module wing_tip_details() {
    // Wing tip shaping (optional sawtooth for stealth)
    if (sawtooth_edges) {
        // Add serrations to wing tip trailing edge
    }
}

// Position wings relative to fuselage
module wings_positioned() {
    // Wings attach at fuselage station
    // Fuselage center at x=0, wing root LE at ~25% fuselage length
    wing_root_le_x = -fuse_length/2 + fuse_length * 0.28;
    wing_root_z = fuse_height_max * 0.15;  // Slightly above fuselage centerline
    
    translate([wing_root_le_x, 0, wing_root_z]) {
        wings();
    }
}

// For standalone preview
wings_positioned();