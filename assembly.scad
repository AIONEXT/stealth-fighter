// Stealth Fighter Main Assembly
// =============================
// Master assembly file - includes all components

// ============================================================
// CONFIGURATION
// ============================================================
include <config.scad>

// ============================================================
// COMPONENT INCLUDES
// ============================================================
include <fuselage.scad>
include <wings.scad>
include <stabilizers.scad>
include <canopy.scad>
include <cockpit.scad>
include <intakes.scad>
include <exhausts.scad>
include <baydoors.scad>
include <landing_gear.scad>

// ============================================================
// DISPLAY STATE OVERRIDES (for preview)
// ============================================================
// These can be overridden in config.scad or via command line
// show_open_doors = false;
// show_gear_down = true;
// show_pilot = false;
// show_weapons = true;

// ============================================================
// MAIN ASSEMBLY
// ============================================================
module stealth_fighter_assembly() {
    $fn = resolution;
    
    // Fuselage (base component)
    if (show_fuselage) {
        fuselage_assembly();
    }
    
    // Wings positioned on fuselage
    if (show_wings) {
        wings_positioned();
    }
    
    // Stabilizers (V-tail or conventional) at aft fuselage
    if (show_stabilizers) {
        stabilizers_positioned();
    }
    
    // Canopy on top of fuselage
    if (show_canopy) {
        canopy();
    }
    
    // Cockpit interior (inside canopy)
    if (show_cockpit) {
        cockpit();
    }
    
    // Engine intakes
    if (show_intakes) {
        intakes();
    }
    
    // Engine exhausts
    if (show_exhausts) {
        exhausts();
    }
    
    // Weapon bay doors
    if (show_bay_doors) {
        if (show_open_doors) {
            bay_doors_open();
        } else {
            bay_doors_closed();
        }
    }
    
    // Landing gear
    if (show_landing_gear) {
        landing_gear();
    }
}

// ============================================================
// PREVIEW CONFIGURATIONS
// ============================================================

// Default preview (clean configuration)
stealth_fighter_assembly();

// Uncomment for specific configurations:
// show_open_doors = true;  stealth_fighter_assembly();  // Combat config
// show_gear_down = false; stealth_fighter_assembly();  // Clean config
// show_pilot = true;       stealth_fighter_assembly();  // Display config

// ============================================================
// EXPORT MODULE (for STL generation)
// ============================================================
// To export STLs, set export_stl = true in config.scad
// and uncomment the desired export module in export.scad
// include <export.scad>