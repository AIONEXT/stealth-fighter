// Export Helper Functions
// =======================
// Functions and modules for exporting STL files for 3D printing
// Usage: Set export_stl = true in config.scad and render individual modules

include <config.scad>

// ============================================================
// EXPORT QUALITY SETTINGS
// ============================================================
function export_resolution(quality) =
    quality == "low" ? 30 :
    quality == "medium" ? 60 :
    quality == "high" ? 100 :
    quality == "ultra" ? 200 : 100;

// Override resolution for export
$fn = export_stl ? export_resolution(stl_quality) : resolution;

// ============================================================
// INDIVIDUAL PART EXPORTS
// ============================================================

// Export fuselage as separate STL
module export_fuselage() {
    if (export_stl && export_individual) {
        // Render just the fuselage
        fuselage_assembly();
    }
}

// Export wings (left and right separate for printing)
module export_wings() {
    if (export_stl && export_individual) {
        // Left wing
        translate([wing_root_le_x, 0, wing_root_z])
        mirror([0, 1, 0]) {
            wings();
        }
        
        // Right wing
        translate([wing_root_le_x, 0, wing_root_z])
        wings();
    }
}

// Export stabilizers
module export_stabilizers() {
    if (export_stl && export_individual) {
        stabilizers_positioned();
    }
}

// Export canopy
module export_canopy() {
    if (export_stl && export_individual) {
        canopy();
    }
}

// Export cockpit interior
module export_cockpit() {
    if (export_stl && export_individual) {
        cockpit();
    }
}

// Export intakes
module export_intakes() {
    if (export_stl && export_individual) {
        intakes();
    }
}

// Export exhausts
module export_exhausts() {
    if (export_stl && export_individual) {
        exhausts();
    }
}

// Export bay doors (closed and open versions)
module export_bay_doors() {
    if (export_stl && export_individual) {
        // Closed
        translate([0, 0, 0])
        bay_doors_closed();
        
        // Open (separate file)
        translate([200 * global_scale, 0, 0])
        bay_doors_open();
    }
}

// Export landing gear
module export_landing_gear() {
    if (export_stl && export_individual) {
        landing_gear();
    }
}

// Export weapons
module export_weapons() {
    if (export_stl && export_individual && show_weapons) {
        // AAM missile
        translate([0, 0, 0])
        aam_missile();
        
        // AGM missile
        translate([weapon_length * 1.5, 0, 0])
        agm_missile();
    }
}

// ============================================================
// ASSEMBLY EXPORTS (Full aircraft in different configurations)
// ============================================================

// Clean configuration (gear up, doors closed)
module export_clean_config() {
    if (export_stl && export_assembly) {
        // Override display options for clean config
        show_landing_gear = false;
        show_open_doors = false;
        show_gear_down = false;
        
        stealth_fighter_assembly();
    }
}

// Landing configuration (gear down, doors closed)
module export_landing_config() {
    if (export_stl && export_assembly) {
        show_landing_gear = true;
        show_gear_down = true;
        show_open_doors = false;
        
        stealth_fighter_assembly();
    }
}

// Combat configuration (gear up, bay doors open)
module export_combat_config() {
    if (export_stl && export_assembly) {
        show_landing_gear = false;
        show_gear_down = false;
        show_open_doors = true;
        
        stealth_fighter_assembly();
    }
}

// Display configuration (gear down, bay doors open, pilot visible)
module export_display_config() {
    if (export_stl && export_assembly) {
        show_landing_gear = true;
        show_gear_down = true;
        show_open_doors = true;
        show_pilot = true;
        show_weapons = true;
        
        stealth_fighter_assembly();
    }
}

// ============================================================
// PRINT-ORIENTED PARTS (Split for 3D printing)
// ============================================================

// Fuselage split into printable sections
module export_fuselage_sections() {
    if (export_stl && export_individual) {
        // Forward fuselage (nose to cockpit)
        translate([0, 0, 0])
        color("red")
        forward_fuselage_section();
        
        // Mid fuselage (cockpit to weapon bay)
        translate([0, 80 * global_scale, 0])
        color("green")
        mid_fuselage_section();
        
        // Aft fuselage (weapon bay to tail)
        translate([0, 160 * global_scale, 0])
        color("blue")
        aft_fuselage_section();
    }
}

module forward_fuselage_section() {
    // Nose section up to cockpit
    diff() {
        fuselage();
        
        // Cut at cockpit frame
        translate([-fuse_length/2 + fuse_length * 0.3, 0, 0])
        cube([fuse_length * 0.7, fuse_width_max * 2, fuse_height_max * 2], center=true);
    }
}

module mid_fuselage_section() {
    // Cockpit to aft weapon bay
    diff() {
        translate([-fuse_length/2 + fuse_length * 0.3, 0, 0])
        fuselage();
        
        // Cut forward
        cube([fuse_length * 0.3, fuse_width_max * 2, fuse_height_max * 2], center=true);
        
        // Cut aft
        translate([fuse_length * 0.7, 0, 0])
        cube([fuse_length * 0.3, fuse_width_max * 2, fuse_height_max * 2], center=true);
    }
}

module aft_fuselage_section() {
    // Aft fuselage with exhaust integration
    diff() {
        translate([-fuse_length/2 + fuse_length * 0.7, 0, 0])
        fuselage();
        
        // Cut forward
        cube([fuse_length * 0.7, fuse_width_max * 2, fuse_height_max * 2], center=true);
    }
}

// Wings split for printing (left/right, each in 2 parts)
module export_wing_panels() {
    if (export_stl && export_individual) {
        // Left wing - inboard
        translate([0, 0, 0])
        left_wing_inboard();
        
        // Left wing - outboard
        translate([0, 100 * global_scale, 0])
        left_wing_outboard();
        
        // Right wing - inboard
        translate([0, 200 * global_scale, 0])
        right_wing_inboard();
        
        // Right wing - outboard
        translate([0, 300 * global_scale, 0])
        right_wing_outboard();
    }
}

module left_wing_inboard() {
    mirror([0, 1, 0]) {
        diff() {
            wings();
            // Cut at 60% span
            translate([0, semi_span * 0.6, 0])
            cube([wing_root_chord * 2, semi_span * 0.4, wing_root_chord], center=true);
        }
    }
}

module left_wing_outboard() {
    mirror([0, 1, 0]) {
        diff() {
            wings();
            // Cut at 60% span
            cube([wing_root_chord * 2, semi_span * 0.6, wing_root_chord], center=true);
        }
    }
}

module right_wing_inboard() {
    diff() {
        wings();
        translate([0, semi_span * 0.6, 0])
        cube([wing_root_chord * 2, semi_span * 0.4, wing_root_chord], center=true);
    }
}

module right_wing_outboard() {
    diff() {
        wings();
        cube([wing_root_chord * 2, semi_span * 0.6, wing_root_chord], center=true);
    }
}

// Stabilizers split
module export_stab_panels() {
    if (export_stl && export_individual) {
        if (stab_type == "vtail") {
            // V-tail surfaces
            translate([0, 0, 0])
            vtail_surface(-1);  // Left
            
            translate([0, 80 * global_scale, 0])
            vtail_surface(1);   // Right
        } else {
            // Horizontal stab
            translate([0, 0, 0])
            horizontal_stab();
            
            // Vertical stab
            translate([0, 80 * global_scale, 0])
            vertical_stab();
        }
    }
}

// ============================================================
// SUPPORT GENERATION HELPERS
// ============================================================

// Generate tree supports for overhangs
module generate_supports(part_name) {
    if (export_stl && print_supports == "tree") {
        echo(str("Generating tree supports for: ", part_name));
        // In practice, use slicer for supports
        // This is a placeholder for documentation
    }
}

// Print orientation helper
module print_orientation_guide() {
    // Show recommended print orientation
    if (export_stl) {
        echo(str("Recommended print orientation: ", print_orientation));
        echo(str("Layer height: ", print_layer_height, "mm"));
        echo(str("Infill: ", print_infill));
        echo(str("Material: ", print_material));
        echo(str("Nozzle temp: ", print_nozzle_temp, "C"));
        echo(str("Bed temp: ", print_bed_temp, "C"));
    }
}

// ============================================================
// BILL OF MATERIALS (for multi-part printing)
// ============================================================
function bom() = [
    ["Part", "Qty", "Material", "Est. Weight (g)", "Print Time (hrs)"],
    ["Fuselage (3 sections)", "1", print_material, 60, 8],
    ["Left Wing (2 panels)", "1", print_material, 25, 4],
    ["Right Wing (2 panels)", "1", print_material, 25, 4],
    ["Stabilizers", "2", print_material, 10, 2],
    ["Canopy", "1", "Clear/Translucent", 8, 1.5],
    ["Cockpit Interior", "1", print_material, 15, 2],
    ["Intakes (pair)", "1", print_material, 12, 2],
    ["Exhausts (pair)", "1", print_material, 10, 1.5],
    ["Bay Doors", "2", print_material, 8, 1.5],
    ["Landing Gear (nose + 2 main)", "1", print_material, 15, 2.5],
    ["Weapons (4 missiles)", "4", print_material, 5, 1],
    ["Total", "", "", "~193", "~27"]
];

// Print BOM to console
module print_bom() {
    if (export_stl) {
        echo("=== BILL OF MATERIALS ===");
        for (row = bom()) {
            echo(row);
        }
        echo("=========================");
    }
}

// ============================================================
// MAIN EXPORT TRIGGER
// ============================================================
// Uncomment the configuration you want to export:

// export_clean_config();      // Clean config (gear up, doors closed)
// export_landing_config();    // Landing config (gear down)
// export_combat_config();     // Combat config (bay doors open)
// export_display_config();    // Display config (full detail)

// Individual parts:
// export_fuselage();
// export_wings();
// export_stabilizers();
// export_canopy();
// export_cockpit();
// export_intakes();
// export_exhausts();
// export_bay_doors();
// export_landing_gear();
// export_weapons();

// Print-oriented splits:
// export_fuselage_sections();
// export_wing_panels();
// export_stab_panels();

// Print BOM
print_bom();
print_orientation_guide();