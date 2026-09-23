include <config.scad>

module exhausts() {
    if (!show_exhausts) return;
    
    $fn = resolution;
    
    // Exhaust position at aft fuselage
    exhaust_x = fuse_length/2 - aft_fuse_length * 0.2;
    exhaust_y = exhaust_spacing/2;
    exhaust_z = 0;
    
    if (exhaust_type == "2d_vectoring") {
        thrust_vectoring_exhausts();
    } else if (exhaust_type == "axisymmetric") {
        axisymmetric_exhausts();
    } else {
        faceted_exhausts();
    }
}

// ============================================================
// 2D THRUST VECTORING NOZZLES (F-22 style)
// ============================================================
module thrust_vectoring_exhausts() {
    for (side = [-1, 1]) {
        let(y_pos = side * exhaust_y) {
            translate([exhaust_x, y_pos, exhaust_z]) {
                tv_nozzle(side);
            }
        }
    }
    
    // Aft fuselage fairing between nozzles
    nozzle_fairing();
}

module tv_nozzle(side) {
    // 2D rectangular nozzle with thrust vectoring
    // Petals: upper and lower, each can deflect independently
    
    nozzle_w = exhaust_nozzle_width;
    nozzle_h = exhaust_nozzle_height;
    nozzle_len = exhaust_nozzle_length;
    vector_angle = exhaust_thrust_vector;
    
    // Nozzle housing (fixed part)
    nozzle_housing();
    
    // Upper petal (deflects down for nose-up pitch)
    upper_petal(vector_angle);
    
    // Lower petal (deflects down for nose-up pitch)
    lower_petal(vector_angle);
    
    // Side petals (for yaw control - differential)
    side_petals(side);
    
    // Serrated trailing edges (IR reduction)
    if (exhaust_serrations > 0) {
        serrated_edges();
    }
    
    // Afterburner rings (if enabled)
    if (exhaust_afterburner) {
        afterburner_rings();
    }
}

module nozzle_housing() {
    // Fixed nozzle housing / convergent section
    housing_len = nozzle_len * 0.4;
    housing_w = nozzle_w * 1.1;
    housing_h = nozzle_h * 1.1;
    
    // Convergent section
    housing_sections = 6;
    
    for (i = [0 : housing_sections - 2]) {
        let(
            x1 = -housing_len + housing_len * i / (housing_sections - 1),
            x2 = -housing_len + housing_len * (i + 1) / (housing_sections - 1),
            t1 = i / (housing_sections - 1),
            t2 = (i + 1) / (housing_sections - 1),
            w1 = nozzle_w * 1.5 - (nozzle_w * 1.5 - housing_w) * t1,
            w2 = nozzle_w * 1.5 - (nozzle_w * 1.5 - housing_w) * t2,
            h1 = nozzle_h * 2.0 - (nozzle_h * 2.0 - housing_h) * t1,
            h2 = nozzle_h * 2.0 - (nozzle_h * 2.0 - housing_h) * t2
        ) {
            hull() {
                translate([x1, 0, 0])
                tv_nozzle_section(w1, h1);
                translate([x2, 0, 0])
                tv_nozzle_section(w2, h2);
            }
        }
    }
    
    // Housing outer skin
    color("darkgray") {
        translate([-housing_len/2, 0, 0])
        scale([housing_len, housing_w, housing_h])
        sphere(1);
    }
}

module tv_nozzle_section(half_w, half_h) {
    // Rectangular nozzle cross-section with rounded corners
    n = 20;
    pts = [for (i = [0 : n - 1]) 
        let(a = 360 * i / n,
            // Rectangular with rounded corners
            wx = half_w * (abs(cos(a)) > 0.3 ? 1 : 0.3 + 0.7 * abs(cos(a / 0.3))),
            hy = half_h * (abs(sin(a)) > 0.3 ? 1 : 0.3 + 0.7 * abs(sin(a / 0.3)))
        )
        [wx * cos(a), hy * sin(a)]
    ];
    
    linear_extrude(height = 0.01)
    polygon(pts);
}

module upper_petal(deflection) {
    // Upper nozzle petal (deflects downward)
    petal_len = nozzle_len * 0.6;
    petal_w = nozzle_w;
    petal_h = nozzle_h / 2;
    petal_thick = 2 * global_scale;
    
    // Petal rotates around hinge at nozzle exit
    hinge_x = 0;
    
    // Deflected position
    rotate([-deflection, 0, 0]) {
        translate([hinge_x + petal_len/2, 0, petal_h/2])
        color("darkgray") {
            // Petal body
            hull() {
                // Hinge end
                translate([0, 0, 0])
                scale([petal_thick, petal_w, petal_h])
                sphere(1);
                
                // Exit end (slightly flared)
                translate([petal_len, 0, 0])
                scale([petal_thick, petal_w * 1.05, petal_h * 1.05])
                sphere(1);
            }
            
            // Petal actuator fairing
            translate([petal_len * 0.3, 0, -petal_h * 0.6])
            cylinder(h = petal_h * 0.4, r = petal_w * 0.05, center=true);
        }
    }
    
    // Serrations on trailing edge
    if (exhaust_serrations > 0) {
        upper_serrations(deflection);
    }
}

module lower_petal(deflection) {
    // Lower nozzle petal (deflects downward)
    petal_len = nozzle_len * 0.6;
    petal_w = nozzle_w;
    petal_h = nozzle_h / 2;
    petal_thick = 2 * global_scale;
    
    hinge_x = 0;
    
    // Deflected position (downward)
    rotate([-deflection, 0, 0]) {
        translate([hinge_x + petal_len/2, 0, -petal_h/2])
        color("darkgray") {
            // Petal body
            hull() {
                translate([0, 0, 0])
                scale([petal_thick, petal_w, petal_h])
                sphere(1);
                
                translate([petal_len, 0, 0])
                scale([petal_thick, petal_w * 1.05, petal_h * 1.05])
                sphere(1);
            }
            
            // Actuator fairing
            translate([petal_len * 0.3, 0, petal_h * 0.6])
            cylinder(h = petal_h * 0.4, r = petal_w * 0.05, center=true);
        }
    }
    
    // Serrations
    if (exhaust_serrations > 0) {
        lower_serrations(deflection);
    }
}

module side_petals(side) {
    // Side petals for yaw control (differential deflection)
    petal_len = nozzle_len * 0.6;
    petal_w = nozzle_h * 0.5;  // Height of side petal
    petal_h = nozzle_w * 0.3;  // Width of side petal
    petal_thick = 2 * global_scale;
    
    // Side petals can deflect differentially for yaw
    // For now, just show them neutral
    for (s = [-1, 1]) {
        let(y_pos = s * nozzle_w/2) {
            translate([petal_len/2, y_pos, 0])
            color("darkgray") {
                hull() {
                    translate([0, 0, 0])
                    scale([petal_thick, petal_w, petal_h])
                    sphere(1);
                    translate([petal_len, 0, 0])
                    scale([petal_thick, petal_w * 1.05, petal_h * 1.05])
                    sphere(1);
                }
            }
        }
    }
}

module serrated_edges() {
    // Serrated trailing edges for IR signature reduction
    serration_w = nozzle_w / exhaust_serrations;
    serration_d = exhaust_serration_depth;
    
    for (i = [0 : exhaust_serrations - 1]) {
        let(y_pos = -nozzle_w/2 + serration_w/2 + serration_w * i) {
            // Upper serration
            translate([nozzle_len * 0.6, y_pos, nozzle_h/2])
            color("darkgray") {
                polyhedron(
                    points = [
                        [0, -serration_w/2, 0],
                        [0, serration_w/2, 0],
                        [serration_d, 0, -serration_d * 0.5],
                        [0, -serration_w/2, -petal_thick],
                        [0, serration_w/2, -petal_thick],
                        [serration_d, 0, -serration_d * 0.5 - petal_thick]
                    ],
                    faces = [
                        [0, 1, 2], [3, 4, 5],  // Triangular faces
                        [0, 3, 4], [0, 4, 1],  // Side faces
                        [0, 3, 5], [3, 5, 2], [5, 2, 0],
                        [1, 4, 5], [4, 5, 2], [5, 2, 1]
                    ]
                );
            }
            
            // Lower serration
            translate([nozzle_len * 0.6, y_pos, -nozzle_h/2])
            color("darkgray") {
                polyhedron(
                    points = [
                        [0, -serration_w/2, 0],
                        [0, serration_w/2, 0],
                        [serration_d, 0, serration_d * 0.5],
                        [0, -serration_w/2, -petal_thick],
                        [0, serration_w/2, -petal_thick],
                        [serration_d, 0, serration_d * 0.5 - petal_thick]
                    ],
                    faces = [
                        [0, 1, 2], [3, 4, 5],
                        [0, 3, 4], [0, 4, 1],
                        [0, 3, 5], [3, 5, 2], [5, 2, 0],
                        [1, 4, 5], [4, 5, 2], [5, 2, 1]
                    ]
                );
            }
        }
    }
}

module upper_serrations(deflection) {
    // Serrations on upper petal trailing edge
    rotate([-deflection, 0, 0]) {
        serrated_edges();
    }
}

module lower_serrations(deflection) {
    // Serrations on lower petal trailing edge
    rotate([-deflection, 0, 0]) {
        serrated_edges();
    }
}

module afterburner_rings() {
    // Afterburner fuel rings (concentric)
    ring_count = 5;
    ring_r_base = nozzle_w/2 * 1.2;
    
    color("orange", 0.7) {
        for (i = [0 : ring_count - 1]) {
            let(r = ring_r_base * (1 - i * 0.15)) {
                translate([nozzle_len * 0.8 + i * 2, 0, 0])
                rotate([0, 90, 0])
                difference() {
                    cylinder(h = 1, r = r, center=true);
                    cylinder(h = 2, r = r * 0.8, center=true);
                }
            }
        }
    }
}

module nozzle_fairing() {
    // Fairing between nozzles and fuselage
    fairing_len = aft_fuse_length * 0.5;
    fairing_w = exhaust_spacing * 1.5;
    fairing_h = exhaust_nozzle_height * 2;
    
    translate([exhaust_x - fairing_len * 0.3, 0, 0])
    color("darkgray") {
        hull() {
            // Fuselage connection
            translate([0, 0, 0])
            scale([fairing_len, fairing_w, fairing_h])
            sphere(1);
            
            // Nozzle housings
            for (side = [-1, 1]) {
                translate([fairing_len * 0.7, side * exhaust_spacing/2, 0])
                scale([fairing_len * 0.3, exhaust_nozzle_width * 1.2, exhaust_nozzle_height * 1.2])
                sphere(1);
            }
        }
    }
}

// ============================================================
// AXISYMMETRIC NOZZLE (F-35 style round)
// ============================================================
module axisymmetric_exhausts() {
    for (side = [-1, 1]) {
        let(y_pos = side * exhaust_y) {
            translate([exhaust_x, y_pos, exhaust_z]) {
                axisymmetric_nozzle();
            }
        }
    }
}

module axisymmetric_nozzle() {
    // Round convergent-divergent nozzle
    nozzle_dia = exhaust_nozzle_width;
    nozzle_len = exhaust_nozzle_length;
    petal_count = exhaust_petals;
    
    // Convergent section
    conv_len = nozzle_len * 0.4;
    conv_dia_start = nozzle_dia * 2;
    conv_dia_end = nozzle_dia;
    
    for (i = [0 : 5]) {
        let(
            x1 = -conv_len + conv_len * i / 5,
            x2 = -conv_len + conv_len * (i + 1) / 5,
            d1 = conv_dia_start - (conv_dia_start - conv_dia_end) * i / 5,
            d2 = conv_dia_start - (conv_dia_start - conv_dia_end) * (i + 1) / 5
        ) {
            hull() {
                translate([x1, 0, 0])
                cylinder(h = 0.01, r = d1/2, center=true);
                translate([x2, 0, 0])
                cylinder(h = 0.01, r = d2/2, center=true);
            }
        }
    }
    
    // Divergent section with petals
    div_len = nozzle_len * 0.6;
    div_dia_start = nozzle_dia;
    div_dia_end = nozzle_dia * 1.3;
    
    for (i = [0 : 8]) {
        let(
            x1 = div_len * i / 8,
            x2 = div_len * (i + 1) / 8,
            d1 = div_dia_start + (div_dia_end - div_dia_start) * i / 8,
            d2 = div_dia_start + (div_dia_end - div_dia_start) * (i + 1) / 8
        ) {
            // Petaled exit
            for (p = [0 : petal_count - 1]) {
                let(angle = 360 * p / petal_count) {
                    rotate([0, 0, angle])
                    translate([x1 + (x2 - x1)/2, d1/2 * 0.9, 0])
                    hull() {
                        scale([x2 - x1, d1 * 0.3, d1 * 0.15])
                        sphere(1);
                        translate([0, (d2 - d1) * 0.9, 0])
                        scale([x2 - x1, d2 * 0.3, d2 * 0.15])
                        sphere(1);
                    }
                }
            }
        }
    }
    
    // Serrations if enabled
    if (exhaust_serrations > 0) {
        axisymmetric_serrations();
    }
}

module axisymmetric_serrations() {
    // Sawtooth serrations on round nozzle
    for (i = [0 : exhaust_serrations - 1]) {
        let(angle = 360 * i / exhaust_serrations) {
            rotate([0, 0, angle])
            translate([nozzle_len, nozzle_dia/2 * 1.3, 0])
            color("darkgray") {
                polyhedron(
                    points = [
                        [0, -nozzle_dia/exhaust_serrations/2, 0],
                        [0, nozzle_dia/exhaust_serrations/2, 0],
                        [exhaust_serration_depth, 0, 0],
                        [0, -nozzle_dia/exhaust_serrations/2, -2],
                        [0, nozzle_dia/exhaust_serrations/2, -2],
                        [exhaust_serration_depth, 0, -2]
                    ],
                    faces = [
                        [0, 1, 2], [3, 4, 5],
                        [0, 3, 4], [0, 4, 1],
                        [0, 3, 5], [3, 5, 2], [5, 2, 0],
                        [1, 4, 5], [4, 5, 2], [5, 2, 1]
                    ]
                );
            }
        }
    }
}

// ============================================================
// FACETED NOZZLE (F-117 style flat facets for stealth)
// ============================================================
module faceted_exhausts() {
    for (side = [-1, 1]) {
        let(y_pos = side * exhaust_y) {
            translate([exhaust_x, y_pos, exhaust_z]) {
                faceted_nozzle();
            }
        }
    }
}

module faceted_nozzle() {
    // Faceted nozzle - flat surfaces aligned to common angles
    // For maximum stealth (F-117 style)
    
    facet_angles = [0, 15, 30, 45, -15, -30, -45];  // Facet angles
    nozzle_len = exhaust_nozzle_length;
    nozzle_w = exhaust_nozzle_width;
    nozzle_h = exhaust_nozzle_height;
    
    // Build as series of flat facets
    facets = len(facet_angles);
    
    for (i = [0 : facets - 1]) {
        let(angle = facet_angles[i]) {
            // Each facet is a flat plate
            rotate([angle, 0, 0])
            translate([nozzle_len/2, 0, 0])
            color("darkgray") {
                // Facet panel
                linear_extrude(height = nozzle_len / facets)
                polygon([
                    [-nozzle_w/2, -nozzle_h/2/facets],
                    [nozzle_w/2, -nozzle_h/2/facets],
                    [nozzle_w/2, nozzle_h/2/facets],
                    [-nozzle_w/2, nozzle_h/2/facets]
                ]);
            }
        }
    }
    
    // Cooling slots / ejector
    faceted_cooling();
}

module faceted_cooling() {
    // Cooling air ejector slots
    slot_count = 12;
    slot_w = nozzle_w / slot_count * 0.6;
    slot_h = 2 * global_scale;
    
    color("darkgray") {
        for (i = [0 : slot_count - 1]) {
            let(y_pos = -nozzle_w/2 + nozzle_w * i / slot_count) {
                translate([nozzle_len * 0.8, y_pos, 0])
                cube([nozzle_len * 0.2, slot_w, slot_h], center=true);
            }
        }
    }
}

// For standalone preview
exhausts();
