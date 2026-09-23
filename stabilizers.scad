include <config.scad>

module stabilizers() {
    if (!show_stabilizers) return;
    
    $fn = resolution;
    
    if (stab_type == "vtail") {
        vtail();
    } else {
        conventional_tail();
    }
}

// ============================================================
// V-TAIL (All-moving ruddervators)
// ============================================================
module vtail() {
    // V-tail geometry
    semi_span = stab_span;
    taper_ratio = stab_tip_chord / stab_root_chord;
    
    // V-tail angle from horizontal
    v_angle = stab_dihedral;  // degrees
    
    // Leading/trailing edge sweep
    le_root_x = 0;
    le_tip_x = semi_span * tan(stab_sweep_le);
    te_root_x = stab_root_chord;
    te_tip_x = le_tip_x + stab_tip_chord;
    
    // Build V-tail surfaces (2 surfaces at +/- v_angle)
    for (side = [-1, 1]) {
        let(angle = side * v_angle) {
            // Rotate the entire surface
            rotate([angle, 0, 0]) {
                vtail_surface(side);
            }
        }
    }
    
    // Tail boom / fuselage integration fairing
    vtail_fairing();
}

module vtail_surface(side) {
    stab_sections = 12;
    
    for (i = [0 : stab_sections - 2]) {
        let(
            // Spanwise position (from root to tip)
            y1 = semi_span * i / (stab_sections - 1),
            y2 = semi_span * (i + 1) / (stab_sections - 1),
            eta1 = i / (stab_sections - 1),
            eta2 = (i + 1) / (stab_sections - 1),
            
            // Local chord
            chord1 = stab_root_chord * (1 - eta1 * (1 - taper_ratio)),
            chord2 = stab_root_chord * (1 - eta2 * (1 - taper_ratio)),
            
            // Leading edge position
            le_x1 = le_root_x + y1 * tan(stab_sweep_le),
            le_x2 = le_root_x + y2 * tan(stab_sweep_le),
            
            // Thickness
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta2,
            
            // Twist
            twist1 = stab_twist * eta1,
            twist2 = stab_twist * eta2
        ) {
            // V-tail segment (in rotated coordinates, y is along span, z is up)
            vtail_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, twist1, twist2);
        }
    }
    
    // All-moving ruddervator (if enabled)
    if (stab_all_moving) {
        vtail_ruddervator(side);
    }
}

module vtail_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, twist1, twist2) {
    // Use same airfoil function as wings
    pts1 = airfoil_points(chord1, thick1);
    pts2 = airfoil_points(chord2, thick2);
    
    // Transform to 3D (in V-tail local coordinates: x forward, y span, z up)
    pts1_3d = [for (p = pts1) [le_x1 + p[0], y1, p[1]]];
    pts2_3d = [for (p = pts2) [le_x2 + p[0], y2, p[1]]];
    
    // Apply twist (rotate around quarter-chord)
    qc1 = le_x1 + 0.25 * chord1;
    qc2 = le_x2 + 0.25 * chord2;
    
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(twist1) - dz * sin(twist1), p[1], dx * sin(twist1) + dz * cos(twist1)]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(twist2) - dz * sin(twist2), p[1], dx * sin(twist2) + dz * cos(twist2)]];
    
    // Loft using hull
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_twisted);
        linear_extrude(height = 0.01)
        polygon(pts2_twisted);
    }
}

module vtail_ruddervator(side) {
    // Ruddervator spans inner 60% of V-tail
    rud_span_ratio = 0.6;
    rud_chord_ratio = stab_surface_chord_ratio;
    rud_deflection_angle = side * stab_deflection;  // Opposite deflection for roll/yaw mixing
    
    rud_root_y = semi_span * (1 - rud_span_ratio);
    rud_tip_y = semi_span;
    
    rud_sections = 8;
    
    for (i = [0 : rud_sections - 2]) {
        let(
            eta1 = i / (rud_sections - 1),
            eta2 = (i + 1) / (rud_sections - 1),
            y1 = rud_root_y + (rud_tip_y - rud_root_y) * eta1,
            y2 = rud_root_y + (rud_tip_y - rud_root_y) * eta2,
            
            // Wing geometry at these stations
            eta_wing1 = y1 / semi_span,
            eta_wing2 = y2 / semi_span,
            chord1 = stab_root_chord * (1 - eta_wing1 * (1 - taper_ratio)),
            chord2 = stab_root_chord * (1 - eta_wing2 * (1 - taper_ratio)),
            le_x1 = le_root_x + y1 * tan(stab_sweep_le),
            le_x2 = le_root_x + y2 * tan(stab_sweep_le),
            te_x1 = le_x1 + chord1,
            te_x2 = le_x2 + chord2,
            hinge_x1 = te_x1 - chord1 * rud_chord_ratio,
            hinge_x2 = te_x2 - chord2 * rud_chord_ratio,
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_wing1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_wing2,
            twist1 = stab_twist * eta_wing1,
            twist2 = stab_twist * eta_wing2
        ) {
            vtail_ruddervator_segment(
                hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, 
                thick1, thick2, twist1, twist2, rud_deflection_angle
            );
        }
    }
}

module vtail_ruddervator_segment(hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, thick1, thick2, twist1, twist2, deflection) {
    cs_chord1 = te_x1 - hinge_x1;
    cs_chord2 = te_x2 - hinge_x2;
    cs_thick1 = thick1 * 0.5;
    cs_thick2 = thick2 * 0.5;
    
    pts1 = airfoil_points(cs_chord1, cs_thick1 / cs_chord1);
    pts2 = airfoil_points(cs_chord2, cs_thick2 / cs_chord2);
    
    pts1_3d = [for (p = pts1) [hinge_x1 + p[0], y1, p[1]]];
    pts2_3d = [for (p = pts2) [hinge_x2 + p[0], y2, p[1]]];
    
    // Apply twist + deflection around hinge
    qc1 = hinge_x1;
    qc2 = hinge_x2;
    
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(twist1) - dz * sin(twist1), p[1], dx * sin(twist1) + dz * cos(twist1)]];
    
    pts1_deflected = [for (p = pts1_twisted)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(deflection) - dz * sin(deflection), p[1], dx * sin(deflection) + dz * cos(deflection)]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(twist2) - dz * sin(twist2), p[1], dx * sin(twist2) + dz * cos(twist2)]];
    
    pts2_deflected = [for (p = pts2_twisted)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(deflection) - dz * sin(deflection), p[1], dx * sin(deflection) + dz * cos(deflection)]];
    
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_deflected);
        linear_extrude(height = 0.01)
        polygon(pts2_deflected);
    }
}

module vtail_fairing() {
    // Fairing at V-tail root where it meets fuselage
    fairing_len = 15 * global_scale;
    fairing_h = stab_root_chord * stab_thickness_root * 2;
    
    translate([-fairing_len * 0.2, 0, 0])
    hull() {
        // Fuselage connection
        translate([0, 0, 0])
        scale([fairing_len, 1, 1])
        sphere(fairing_h/2);
        
        // V-tail roots
        for (side = [-1, 1]) {
            rotate([side * stab_dihedral, 0, 0])
            translate([stab_root_chord * 0.15, 0, 0])
            scale([fairing_len * 0.5, stab_root_chord * 0.3, fairing_h])
            sphere(1);
        }
    }
}

// ============================================================
// CONVENTIONAL TAIL (Horizontal + Vertical)
// ============================================================
module conventional_tail() {
    // Horizontal stabilizer
    horizontal_stab();
    
    // Vertical stabilizer
    vertical_stab();
    
    // Tail fairing
    tail_fairing();
}

module horizontal_stab() {
    semi_span = stab_span;
    taper_ratio = stab_tip_chord / stab_root_chord;
    
    stab_sections = 10;
    
    for (i = [0 : stab_sections - 2]) {
        let(
            y1 = semi_span * i / (stab_sections - 1),
            y2 = semi_span * (i + 1) / (stab_sections - 1),
            eta1 = i / (stab_sections - 1),
            eta2 = (i + 1) / (stab_sections - 1),
            chord1 = stab_root_chord * (1 - eta1 * (1 - taper_ratio)),
            chord2 = stab_root_chord * (1 - eta2 * (1 - taper_ratio)),
            le_x1 = le_root_x + y1 * tan(stab_sweep_le),
            le_x2 = le_root_x + y2 * tan(stab_sweep_le),
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta2,
            twist1 = stab_twist * eta1,
            twist2 = stab_twist * eta2
        ) {
            // Horizontal stab segment (z=0 plane)
            hstab_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, twist1, twist2);
        }
    }
    
    // Elevator (all-moving or hinged)
    if (stab_all_moving) {
        horizontal_elevator();
    }
}

module hstab_segment(y1, y2, le_x1, le_x2, chord1, chord2, thick1, thick2, twist1, twist2) {
    pts1 = airfoil_points(chord1, thick1);
    pts2 = airfoil_points(chord2, thick2);
    
    pts1_3d = [for (p = pts1) [le_x1 + p[0], y1, p[1]]];
    pts2_3d = [for (p = pts2) [le_x2 + p[0], y2, p[1]]];
    
    qc1 = le_x1 + 0.25 * chord1;
    qc2 = le_x2 + 0.25 * chord2;
    
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(twist1) - dz * sin(twist1), p[1], dx * sin(twist1) + dz * cos(twist1)]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(twist2) - dz * sin(twist2), p[1], dx * sin(twist2) + dz * cos(twist2)]];
    
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_twisted);
        linear_extrude(height = 0.01)
        polygon(pts2_twisted);
    }
    
    // Mirror for other side
    mirror([0, 1, 0]) {
        hull() {
            linear_extrude(height = 0.01)
            polygon([for (p = pts1_twisted) [p[0], -p[1], p[2]]]);
            linear_extrude(height = 0.01)
            polygon([for (p = pts2_twisted) [p[0], -p[1], p[2]]]);
        }
    }
}

module horizontal_elevator() {
    // Elevator on trailing edge
    elev_span_ratio = 0.7;
    elev_chord_ratio = stab_surface_chord_ratio;
    
    elev_root_y = semi_span * (1 - elev_span_ratio);
    elev_tip_y = semi_span;
    
    elev_sections = 6;
    
    for (i = [0 : elev_sections - 2]) {
        let(
            eta1 = i / (elev_sections - 1),
            eta2 = (i + 1) / (elev_sections - 1),
            y1 = elev_root_y + (elev_tip_y - elev_root_y) * eta1,
            y2 = elev_root_y + (elev_tip_y - elev_root_y) * eta2,
            eta_wing1 = y1 / semi_span,
            eta_wing2 = y2 / semi_span,
            chord1 = stab_root_chord * (1 - eta_wing1 * (1 - taper_ratio)),
            chord2 = stab_root_chord * (1 - eta_wing2 * (1 - taper_ratio)),
            le_x1 = le_root_x + y1 * tan(stab_sweep_le),
            le_x2 = le_root_x + y2 * tan(stab_sweep_le),
            te_x1 = le_x1 + chord1,
            te_x2 = le_x2 + chord2,
            hinge_x1 = te_x1 - chord1 * elev_chord_ratio,
            hinge_x2 = te_x2 - chord2 * elev_chord_ratio,
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_wing1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_wing2,
            twist1 = stab_twist * eta_wing1,
            twist2 = stab_twist * eta_wing2
        ) {
            // Elevator segment (deflected)
            elevator_segment(hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, thick1, thick2, twist1, twist2, stab_deflection);
            
            // Mirror
            mirror([0, 1, 0]) {
                elevator_segment(hinge_x1, hinge_x2, te_x1, te_x2, -y1, -y2, thick1, thick2, twist1, twist2, stab_deflection);
            }
        }
    }
}

module elevator_segment(hinge_x1, hinge_x2, te_x1, te_x2, y1, y2, thick1, thick2, twist1, twist2, deflection) {
    cs_chord1 = te_x1 - hinge_x1;
    cs_chord2 = te_x2 - hinge_x2;
    cs_thick1 = thick1 * 0.5;
    cs_thick2 = thick2 * 0.5;
    
    pts1 = airfoil_points(cs_chord1, cs_thick1 / cs_chord1);
    pts2 = airfoil_points(cs_chord2, cs_thick2 / cs_chord2);
    
    pts1_3d = [for (p = pts1) [hinge_x1 + p[0], y1, p[1]]];
    pts2_3d = [for (p = pts2) [hinge_x2 + p[0], y2, p[1]]];
    
    qc1 = hinge_x1;
    qc2 = hinge_x2;
    
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(twist1) - dz * sin(twist1), p[1], dx * sin(twist1) + dz * cos(twist1)]];
    
    pts1_deflected = [for (p = pts1_twisted)
        let(dx = p[0] - qc1, dz = p[2])
        [qc1 + dx * cos(deflection) - dz * sin(deflection), p[1], dx * sin(deflection) + dz * cos(deflection)]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(twist2) - dz * sin(twist2), p[1], dx * sin(twist2) + dz * cos(twist2)]];
    
    pts2_deflected = [for (p = pts2_twisted)
        let(dx = p[0] - qc2, dz = p[2])
        [qc2 + dx * cos(deflection) - dz * sin(deflection), p[1], dx * sin(deflection) + dz * cos(deflection)]];
    
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_deflected);
        linear_extrude(height = 0.01)
        polygon(pts2_deflected);
    }
}

module vertical_stab() {
    // Single vertical tail (or twin - configurable)
    vtail_span_local = vtail_span;
    vtaper = vtail_tip_chord / vtail_root_chord;
    
    vt_sections = 10;
    
    for (i = [0 : vt_sections - 2]) {
        let(
            z1 = vtail_span_local * i / (vt_sections - 1),
            z2 = vtail_span_local * (i + 1) / (vt_sections - 1),
            eta1 = i / (vt_sections - 1),
            eta2 = (i + 1) / (vt_sections - 1),
            chord1 = vtail_root_chord * (1 - eta1 * (1 - vtaper)),
            chord2 = vtail_root_chord * (1 - eta2 * (1 - vtaper)),
            le_x1 = le_root_x + z1 * tan(vtail_sweep_le),
            le_x2 = le_root_x + z2 * tan(vtail_sweep_le),
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta2
        ) {
            vtail_vertical_segment(z1, z2, le_x1, le_x2, chord1, chord2, thick1, thick2);
        }
    }
    
    // Rudder
    if (stab_all_moving) {
        vertical_rudder();
    }
}

module vtail_vertical_segment(z1, z2, le_x1, le_x2, chord1, chord2, thick1, thick2) {
    pts1 = airfoil_points(chord1, thick1);
    pts2 = airfoil_points(chord2, thick2);
    
    // Vertical: x forward, y=0, z up
    pts1_3d = [for (p = pts1) [le_x1 + p[0], 0, z1 + p[1]]];
    pts2_3d = [for (p = pts2) [le_x2 + p[0], 0, z2 + p[1]]];
    
    qc1 = le_x1 + 0.25 * chord1;
    qc2 = le_x2 + 0.25 * chord2;
    
    // No twist for vertical tail typically
    pts1_twisted = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2] - z1)
        [qc1 + dx, p[1], z1 + dz]];
    
    pts2_twisted = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2] - z2)
        [qc2 + dx, p[1], z2 + dz]];
    
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_twisted);
        linear_extrude(height = 0.01)
        polygon(pts2_twisted);
    }
    
    // Mirror for twin tail (if desired)
    // mirror([1, 0, 0]) { ... }
}

module vertical_rudder() {
    rud_span_ratio = 0.8;
    rud_chord_ratio = stab_surface_chord_ratio;
    
    rud_root_z = vtail_span_local * (1 - rud_span_ratio);
    rud_tip_z = vtail_span_local;
    
    rud_sections = 6;
    
    for (i = [0 : rud_sections - 2]) {
        let(
            eta1 = i / (rud_sections - 1),
            eta2 = (i + 1) / (rud_sections - 1),
            z1 = rud_root_z + (rud_tip_z - rud_root_z) * eta1,
            z2 = rud_root_z + (rud_tip_z - rud_root_z) * eta2,
            eta_vtail1 = z1 / vtail_span_local,
            eta_vtail2 = z2 / vtail_span_local,
            chord1 = vtail_root_chord * (1 - eta_vtail1 * (1 - vtaper)),
            chord2 = vtail_root_chord * (1 - eta_vtail2 * (1 - vtaper)),
            le_x1 = le_root_x + z1 * tan(vtail_sweep_le),
            le_x2 = le_root_x + z2 * tan(vtail_sweep_le),
            te_x1 = le_x1 + chord1,
            te_x2 = le_x2 + chord2,
            hinge_x1 = te_x1 - chord1 * rud_chord_ratio,
            hinge_x2 = te_x2 - chord2 * rud_chord_ratio,
            thick1 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_vtail1,
            thick2 = stab_thickness_root - (stab_thickness_root - stab_thickness_tip) * eta_vtail2
        ) {
            rudder_segment(hinge_x1, hinge_x2, te_x1, te_x2, z1, z2, thick1, thick2, rudder_deflection);
        }
    }
}

module rudder_segment(hinge_x1, hinge_x2, te_x1, te_x2, z1, z2, thick1, thick2, deflection) {
    cs_chord1 = te_x1 - hinge_x1;
    cs_chord2 = te_x2 - hinge_x2;
    cs_thick1 = thick1 * 0.5;
    cs_thick2 = thick2 * 0.5;
    
    pts1 = airfoil_points(cs_chord1, cs_thick1 / cs_chord1);
    pts2 = airfoil_points(cs_chord2, cs_thick2 / cs_chord2);
    
    pts1_3d = [for (p = pts1) [hinge_x1 + p[0], 0, z1 + p[1]]];
    pts2_3d = [for (p = pts2) [hinge_x2 + p[0], 0, z2 + p[1]]];
    
    qc1 = hinge_x1;
    qc2 = hinge_x2;
    
    pts1_deflected = [for (p = pts1_3d)
        let(dx = p[0] - qc1, dz = p[2] - z1)
        [qc1 + dx * cos(deflection) - dz * sin(deflection), p[1], z1 + dx * sin(deflection) + dz * cos(deflection)]];
    
    pts2_deflected = [for (p = pts2_3d)
        let(dx = p[0] - qc2, dz = p[2] - z2)
        [qc2 + dx * cos(deflection) - dz * sin(deflection), p[1], z2 + dx * sin(deflection) + dz * cos(deflection)]];
    
    hull() {
        linear_extrude(height = 0.01)
        polygon(pts1_deflected);
        linear_extrude(height = 0.01)
        polygon(pts2_deflected);
    }
}

module tail_fairing() {
    // Fairing at tail root
    fairing_len = 20 * global_scale;
    fairing_h = max(stab_root_chord, vtail_root_chord) * stab_thickness_root * 2;
    
    translate([-fairing_len * 0.2, 0, 0])
    hull() {
        translate([0, 0, 0])
        scale([fairing_len, 1, 1])
        sphere(fairing_h/2);
        
        translate([stab_root_chord * 0.2, 0, 0])
        scale([fairing_len * 0.5, stab_span * 0.2, fairing_h])
        sphere(1);
        
        translate([vtail_root_chord * 0.2, 0, vtail_span * 0.3])
        scale([fairing_len * 0.5, 1, vtail_span * 0.3])
        sphere(1);
    }
}

// ============================================================
// AIRFOIL FUNCTION (shared with wings)
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
// POSITIONING RELATIVE TO FUSELAGE
// ============================================================
module stabilizers_positioned() {
    // V-tail or conventional tail at aft fuselage
    tail_x = fuse_length/2 - aft_fuse_length * 0.3;
    tail_z = fuse_height_max * 0.1;  // Slightly above centerline
    
    translate([tail_x, 0, tail_z]) {
        stabilizers();
    }
}

// For standalone preview
stabilizers_positioned();