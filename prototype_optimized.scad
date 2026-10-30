include <config.scad>

// Optimized, print-ready prototype geometry for the stealth fighter.
// This version prioritizes stable wall thickness, simple union geometry,
// and multipart print layout while retaining the aircraft silhouette.

module prototype_fuselage() {
    // Main body: thickened, rounded, and easy for slicers to resolve.
    hull() {
        translate([-fuse_length * 0.56, 0, 0])
            scale([0.26, 0.40, 0.52]) sphere(1);

        translate([-fuse_length * 0.30, 0, 0])
            scale([0.52, 0.66, 0.78]) sphere(1);

        translate([0, 0, 0])
            scale([0.72, 0.82, 0.90]) sphere(1);

        translate([fuse_length * 0.26, 0, 0])
            scale([0.60, 0.72, 0.76]) sphere(1);

        translate([fuse_length * 0.42, 0, 0])
            scale([0.30, 0.42, 0.48]) sphere(1);
    }
}

module prototype_canopy() {
    translate([-fuse_length * 0.12, 0, fuse_height_max * 0.30])
        scale([0.90, 0.65, 0.82])
        sphere(12 * global_scale);
}

module prototype_wing_half(side = 1) {
    y_offset = side * (wing_span * 0.42 + fuse_width_max * 0.25);
    z_offset = fuse_height_max * 0.14;

    hull() {
        translate([-fuse_length * 0.12, y_offset, z_offset])
            scale([0.55, 0.48, 0.18]) sphere(1);

        translate([0, y_offset + side * wing_span * 0.14, z_offset])
            scale([1.8, 0.72, 0.18]) sphere(1);

        translate([fuse_length * 0.22, y_offset + side * wing_span * 0.31, z_offset - fuse_height_max * 0.02])
            scale([1.3, 0.42, 0.14]) sphere(1);

        translate([fuse_length * 0.34, y_offset + side * wing_span * 0.48, z_offset - fuse_height_max * 0.05])
            scale([0.70, 0.24, 0.10]) sphere(1);
    }
}

module prototype_tail_half(side = 1) {
    y_offset = side * (stab_span * 0.95);
    x_offset = fuse_length * 0.42;
    z_offset = fuse_height_max * 0.36;

    hull() {
        translate([x_offset, y_offset, z_offset])
            scale([0.50, 0.38, 0.14]) sphere(1);

        translate([x_offset + stab_root_chord * 0.30, y_offset + side * stab_span * 0.38, z_offset + stab_span * 0.15])
            scale([0.90, 0.42, 0.16]) sphere(1);

        translate([x_offset + stab_root_chord * 0.55, y_offset + side * stab_span * 0.72, z_offset + stab_span * 0.30])
            scale([0.60, 0.24, 0.12]) sphere(1);
    }
}

module prototype_intake(side = 1) {
    x = -fuse_length * 0.15;
    y = side * (fuse_width_max * 0.62 + 2 * global_scale);
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
    x = fuse_length * 0.41;
    y = side * (exhaust_spacing / 2);
    z = 0;

    translate([x, y, z])
        rotate([0, 90, 0])
        hull() {
            translate([0, 0, -exhaust_nozzle_length * 0.5])
                scale([1, exhaust_nozzle_width * 0.7, exhaust_nozzle_height * 0.65]) sphere(1);

            translate([exhaust_nozzle_length * 0.7, 0, 0])
                scale([1, exhaust_nozzle_width * 0.45, exhaust_nozzle_height * 0.45]) sphere(1);
        }
}

module prototype_bay_door() {
    color("darkgray")
        translate([-fuse_length * 0.06, 0, -bay_depth * 0.1])
        cube([bay_length * 0.9, bay_width * 0.65, bay_depth * 0.7], center = true);
}

module prototype_nose_gear() {
    translate([-fuse_length * 0.38, 0, -fuse_height_max * 0.55]) {
        color("darkgray") {
            cylinder(h = nose_gear_strut_length, r = 2.3 * global_scale, center = true);
            translate([0, 0, -nose_gear_strut_length * 0.75])
                wheel();
        }
    }
}

module prototype_main_gear(side = 1) {
    translate([-fuse_length * 0.04, side * (fuse_width_max * 0.7), -fuse_height_max * 0.55]) {
        color("darkgray") {
            cylinder(h = main_gear_strut_length, r = 2.4 * global_scale, center = true);
            translate([0, 0, -main_gear_strut_length * 0.70])
                wheel();
        }
    }
}

module prototype_weapon() {
    color("silver")
        hull() {
            scale([0.55, 0.55, 1]) sphere(1.6 * global_scale);
            translate([weapon_length * 0.5, 0, 0])
                scale([0.45, 0.45, 0.80]) sphere(1.4 * global_scale);
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
            translate([-fuse_length * 0.06, -bay_width * 0.35, -bay_depth * 0.2])
                prototype_weapon();
            translate([-fuse_length * 0.06, bay_width * 0.35, -bay_depth * 0.2])
                prototype_weapon();
        }
    }
}

module prototype_print_layout() {
    // Layout for multipart printing with easy separation.
    translate([0, 0, 0]) prototype_fuselage();
    translate([0, wing_span * 0.75, 0]) prototype_wing_half(-1);
    translate([0, -wing_span * 0.75, 0]) prototype_wing_half(1);
    translate([0, wing_span * 1.6, 0]) prototype_tail_half(-1);
    translate([0, -wing_span * 1.6, 0]) prototype_tail_half(1);
}
