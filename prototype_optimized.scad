include <config.scad>

// Optimized, print-ready prototype geometry for the stealth fighter.
// This version prioritizes stable wall thickness, simple union geometry,
// and multipart print layout while retaining the aircraft silhouette.

module prototype_fuselage() {
    // Main body: smooth, area-ruled, and easy for slicers to resolve.
    hull() {
        translate([-fuse_length * 0.58, 0, 0])
            scale([0.22, 0.34, 0.48]) sphere(1);

        translate([-fuse_length * 0.38, 0, 0])
            scale([0.46, 0.58, 0.72]) sphere(1);

        translate([-fuse_length * 0.12, 0, 0])
            scale([0.60, 0.72, 0.82]) sphere(1);

        translate([fuse_length * 0.10, 0, 0])
            scale([0.82, 0.86, 0.90]) sphere(1);

        translate([fuse_length * 0.30, 0, 0])
            scale([0.70, 0.76, 0.78]) sphere(1);

        translate([fuse_length * 0.46, 0, 0])
            scale([0.28, 0.42, 0.48]) sphere(1);
    }
}

module prototype_canopy() {
    // Low-profile canopy with a stealthy, slabbed profile.
    translate([-fuse_length * 0.12, 0, fuse_height_max * 0.28])
        scale([0.90, 0.58, 0.72])
        sphere(12 * global_scale);
}

module prototype_wing_half(side = 1) {
    // More realistic leading-edge sweep with cleaner root-body blending.
    y_base = side * (wing_span * 0.40 + fuse_width_max * 0.22);
    z_base = fuse_height_max * 0.14;

    hull() {
        translate([-fuse_length * 0.12, y_base, z_base])
            scale([0.60, 0.52, 0.18]) sphere(1);

        translate([0, y_base + side * wing_span * 0.10, z_base])
            scale([1.7, 0.74, 0.18]) sphere(1);

        translate([fuse_length * 0.18, y_base + side * wing_span * 0.28, z_base - fuse_height_max * 0.02])
            scale([1.2, 0.44, 0.14]) sphere(1);

        translate([fuse_length * 0.36, y_base + side * wing_span * 0.46, z_base - fuse_height_max * 0.05])
            scale([0.68, 0.24, 0.12]) sphere(1);
    }
}

module prototype_tail_half(side = 1) {
    // V-tail style, but simplified for printability.
    x_offset = fuse_length * 0.42;
    y_offset = side * (stab_span * 0.92);
    z_offset = fuse_height_max * 0.36;

    hull() {
        translate([x_offset, y_offset, z_offset])
            scale([0.44, 0.36, 0.14]) sphere(1);

        translate([x_offset + stab_root_chord * 0.28, y_offset + side * stab_span * 0.32, z_offset + stab_span * 0.12])
            scale([0.92, 0.42, 0.16]) sphere(1);

        translate([x_offset + stab_root_chord * 0.58, y_offset + side * stab_span * 0.72, z_offset + stab_span * 0.28])
            scale([0.56, 0.22, 0.12]) sphere(1);
    }
}

module prototype_intake(side = 1) {
    x = -fuse_length * 0.18;
    y = side * (fuse_width_max * 0.62 + 2.2 * global_scale);
    z = 0;

    translate([x, y, z])
        rotate([0, 90, 0])
        hull() {
            translate([0, 0, -intake_length * 0.5])
                scale([1, intake_width * 0.72, intake_height * 0.72]) sphere(1);

            translate([intake_length * 0.55, 0, 0])
                scale([1, intake_width * 0.64, intake_height * 0.64]) sphere(1);
        }
}

module prototype_exhaust(side = 1) {
    x = fuse_length * 0.39;
    y = side * (exhaust_spacing / 2);

    translate([x, y, 0])
        rotate([0, 90, 0])
        hull() {
            translate([0, 0, -exhaust_nozzle_length * 0.5])
                scale([1, exhaust_nozzle_width * 0.72, exhaust_nozzle_height * 0.66]) sphere(1);

            translate([exhaust_nozzle_length * 0.72, 0, 0])
                scale([1, exhaust_nozzle_width * 0.46, exhaust_nozzle_height * 0.46]) sphere(1);
        }
}

module prototype_bay_door() {
    color("darkgray")
        translate([-fuse_length * 0.06, 0, -bay_depth * 0.1])
        cube([bay_length * 0.9, bay_width * 0.70, bay_depth * 0.7], center = true);
}

module prototype_nose_gear() {
    translate([-fuse_length * 0.38, 0, -fuse_height_max * 0.55]) {
        color("darkgray") {
            cylinder(h = nose_gear_strut_length, r = 2.3 * global_scale, center = true);
            translate([0, 0, -nose_gear_strut_length * 0.78])
                wheel();
        }
    }
}

module prototype_main_gear(side = 1) {
    translate([-fuse_length * 0.06, side * (fuse_width_max * 0.72), -fuse_height_max * 0.55]) {
        color("darkgray") {
            cylinder(h = main_gear_strut_length, r = 2.4 * global_scale, center = true);
            translate([0, 0, -main_gear_strut_length * 0.72])
                wheel();
        }
    }
}

module prototype_weapon() {
    color("silver")
        hull() {
            scale([0.60, 0.60, 1.0]) sphere(1.7 * global_scale);
            translate([weapon_length * 0.52, 0, 0])
                scale([0.44, 0.44, 0.82]) sphere(1.4 * global_scale);
        }
}

module prototype_optimized_assembly() {
    union() {
        prototype_fuselage();
        prototype_wing_half(-1);
        prototype_wing_half(1);
        prototype_tail_half(-1);
        prototype_tail_half(1);
        prototype_canopy();
        prototype_intake(-1);
        prototype_intake(1);
        prototype_exhaust(-1);
        prototype_exhaust(1);
        prototype_bay_door();
        prototype_nose_gear();
        prototype_main_gear(-1);
        prototype_main_gear(1);

        if (show_weapons) {
            translate([-fuse_length * 0.06, -bay_width * 0.38, -bay_depth * 0.2])
                prototype_weapon();
            translate([-fuse_length * 0.06, bay_width * 0.38, -bay_depth * 0.2])
                prototype_weapon();
        }
    }
}

module prototype_print_layout() {
    // Multipart print layout: fuselage body, wings, and stabilizers.
    translate([0, 0, 0]) prototype_fuselage();
    translate([0, wing_span * 0.78, 0]) prototype_wing_half(-1);
    translate([0, -wing_span * 0.78, 0]) prototype_wing_half(1);
    translate([0, wing_span * 1.7, 0]) prototype_tail_half(-1);
    translate([0, -wing_span * 1.7, 0]) prototype_tail_half(1);
}
