// Stealth Fighter Configuration
// ============================
// Global parametric configuration for the stealth fighter aircraft
// Modify these parameters to customize the design

// ============================================================
// GLOBAL SCALE & UNITS
// ============================================================
global_scale = 1.0;              // Overall model scale factor
unit = 1;                        // Base unit (1 = 1mm in OpenSCAD)
resolution = 100;                // Mesh resolution for curved surfaces ($fn)

// ============================================================
// DISPLAY OPTIONS
// ============================================================
show_fuselage = true;
show_wings = true;
show_stabilizers = true;
show_canopy = true;
show_cockpit = true;
show_intakes = true;
show_exhausts = true;
show_bay_doors = true;
show_landing_gear = true;

show_open_doors = false;         // true = open weapon bay doors
show_gear_down = true;           // true = landing gear deployed
show_pilot = false;              // Show pilot figure in cockpit
show_weapons = true;             // Show internal weapons in bays

// ============================================================
// FUSELAGE PARAMETERS
// ============================================================
// Overall fuselage dimensions
fuse_length = 180 * global_scale;
fuse_width_max = 32 * global_scale;
fuse_height_max = 24 * global_scale;

// Nose section
nose_length = 45 * global_scale;
nose_width_base = 18 * global_scale;
nose_height_base = 14 * global_scale;
nose_chine_angle = 35;           // Chine angle for stealth (degrees)

// Forward fuselage (cockpit area)
fwd_fuse_length = 40 * global_scale;
fwd_fuse_width = 28 * global_scale;
fwd_fuse_height = 22 * global_scale;

// Mid fuselage (engine bay / weapon bay)
mid_fuse_length = 60 * global_scale;
mid_fuse_width = 32 * global_scale;
mid_fuse_height = 24 * global_scale;
mid_fuse_chine_width = 22 * global_scale;  // Width at chine line

// Aft fuselage (engine nozzles)
aft_fuse_length = 35 * global_scale;
aft_fuse_width = 30 * global_scale;
aft_fuse_height = 20 * global_scale;

// Area ruling (Coke bottle waist)
area_rule_waist = 0.85;          // Waist ratio at weapon bay (0.7-1.0)
area_rule_position = 0.55;       // Position along length (0-1)

// ============================================================
// WING PARAMETERS
// ============================================================
wing_span = 140 * global_scale;          // Total wingspan (tip to tip)
wing_root_chord = 65 * global_scale;     // Root chord length
wing_tip_chord = 20 * global_scale;      // Tip chord length
wing_sweep_le = 48;                      // Leading edge sweep (degrees)
wing_sweep_te = 15;                      // Trailing edge sweep (degrees)
wing_dihedral = 3;                       // Dihedral angle (degrees)
wing_twist = -2;                         // Washout twist (degrees, negative = washout)
wing_thickness_root = 0.12;              // Thickness/chord ratio at root
wing_thickness_tip = 0.08;               // Thickness/chord ratio at tip
wing_thickness_dist = "cosine";          // "linear" or "cosine" thickness distribution

// Control surfaces
wing_aileron_span_ratio = 0.4;           // Aileron span as fraction of semi-span
wing_aileron_chord_ratio = 0.25;         // Aileron chord as fraction of local chord
wing_flap_span_ratio = 0.35;             // Flap span fraction (inboard)
wing_flap_chord_ratio = 0.3;             // Flap chord fraction
show_control_surfaces = true;            // Show deflected control surfaces
aileron_deflection = 15;                 // Aileron deflection (degrees)
flap_deflection = 25;                    // Flap deflection (degrees)

// Wing-fuselage blending
wing_root_blend = 15 * global_scale;     // Blend radius at root
wing_fairing_length = 25 * global_scale; // Length of wing-body fairing

// ============================================================
// STABILIZER PARAMETERS
// ============================================================
stab_type = "vtail";              // "vtail" or "conventional"
stab_span = 60 * global_scale;    // Span per surface (V-tail) or horizontal span
stab_root_chord = 30 * global_scale;
stab_tip_chord = 12 * global_scale;
stab_sweep_le = 45;
stab_sweep_te = 10;
stab_dihedral = 50;               // V-tail angle from horizontal (degrees)
stab_twist = -1;
stab_thickness_root = 0.1;
stab_thickness_tip = 0.07;

// All-moving surfaces (ruddervators/elevators/rudder)
stab_all_moving = true;
stab_surface_chord_ratio = 0.35;
stab_deflection = 20;             // Max deflection (degrees)
rudder_deflection = 25;           // Rudder deflection for conventional

// Vertical tail (for conventional)
vtail_span = 45 * global_scale;
vtail_root_chord = 35 * global_scale;
vtail_tip_chord = 15 * global_scale;
vtail_sweep_le = 50;
vtail_sweep_te = 15;

// ============================================================
// CANOPY PARAMETERS
// ============================================================
canopy_length = 32 * global_scale;
canopy_width_max = 20 * global_scale;
canopy_height_max = 16 * global_scale;
canopy_position = 0.22;           // Position along fuselage (0-1)
canopy_stealth_coating = true;    // Gold coating representation
canopy_frame_thickness = 1.5 * global_scale;
canopy_frameless = true;          // True = frameless stealth design
canopy_bulge = 1.15;              // Bulge factor for pilot headroom

// ============================================================
// COCKPIT INTERIOR PARAMETERS
// ============================================================
cockpit_floor_z = -8 * global_scale;
seat_width = 10 * global_scale;
seat_depth = 12 * global_scale;
seat_height = 18 * global_scale;
seat_recline = 18;                // Seat back angle (degrees)
seat_headrest_height = 8 * global_scale;

// Ejection seat details
show_ejection_details = true;
seat_handles = true;
seat_rail_height = 4 * global_scale;

// Instrument panel
panel_width = 16 * global_scale;
panel_height = 12 * global_scale;
panel_distance = 20 * global_scale;
panel_angle = 15;                 // Tilt back angle
hud_combiner = true;              // HUD combiner glass

// Side consoles
console_width = 6 * global_scale;
console_height = 20 * global_scale;
console_depth = 8 * global_scale;

// Pilot figure
pilot_height = 35 * global_scale;
pilot_shoulder_width = 12 * global_scale;
pilot_helmet_size = 8 * global_scale;
pilot_visor_tint = true;

// ============================================================
// INTAKE PARAMETERS
// ============================================================
intake_type = "dsi";              // "dsi" (diverterless), "serpentine", "conventional"
intake_position = 0.35;           // Position along fuselage (0-1)
intake_width = 18 * global_scale;
intake_height = 14 * global_scale;
intake_length = 50 * global_scale;
intake_capture_area = 0.025;      // Capture area in m^2 (scaled)
intake_ramp_angle = 12;           // Compression ramp angle
intake_bleed_doors = true;        // Boundary layer bleed doors
intake_serpentine_bends = 2;      // Number of S-bends for serpentine
intake_duct_area_ratio = 1.3;     // Throat to face area ratio

// DSI specific
dsi_bump_height = 8 * global_scale;
dsi_bump_length = 30 * global_scale;
dsi_cowl_angle = 35;

// ============================================================
// EXHAUST PARAMETERS
// ============================================================
exhaust_type = "2d_vectoring";    // "2d_vectoring", "axisymmetric", "faceted"
exhaust_position = 0.92;          // Position along fuselage
exhaust_spacing = 16 * global_scale;  // Center-to-center spacing
exhaust_nozzle_width = 14 * global_scale;
exhaust_nozzle_height = 6 * global_scale;
exhaust_nozzle_length = 25 * global_scale;
exhaust_thrust_vector = 15;       // Thrust vector angle (degrees)
exhaust_serrations = 12;          // Number of serrations for IR reduction
exhaust_serration_depth = 3 * global_scale;
exhaust_petals = 4;               // Number of nozzle petals (axisymmetric)
exhaust_afterburner = false;      // Show afterburner rings

// ============================================================
// WEAPON BAY PARAMETERS
// ============================================================
bay_position = 0.5;               // Position along fuselage (0-1)
bay_length = 40 * global_scale;
bay_width = 22 * global_scale;
bay_depth = 8 * global_scale;
bay_door_thickness = 1.5 * global_scale;
bay_door_angle = 85;              // Open angle (degrees, 90 = fully open)
bay_door_chine = true;            // Chine alignment on doors

// Internal weapons
weapon_type = "aam";              // "aam" (air-to-air), "agm" (air-to-ground), "mixed"
weapon_count = 4;                 // Total weapons (2 per bay typically)
weapon_length = 30 * global_scale;
weapon_diameter = 3.5 * global_scale;
weapon_fin_span = 10 * global_scale;
weapon_fin_chord = 4 * global_scale;
weapon_rail_type = "launcher";    // "launcher" or "ejector"

// ============================================================
// LANDING GEAR PARAMETERS
// ============================================================
gear_type = "retractable";        // "fixed" or "retractable"

// Nose gear
nose_gear_position = 0.15;        // Position along fuselage
nose_gear_strut_length = 25 * global_scale;
nose_gear_wheel_diameter = 12 * global_scale;
nose_gear_wheel_width = 4 * global_scale;
nose_gear_oleo_stroke = 5 * global_scale;
nose_gear_steering = 60;          // Max steering angle
nose_gear_door = true;            // Gear door

// Main gear
main_gear_position = 0.55;        // Position along fuselage
main_gear_strut_length = 22 * global_scale;
main_gear_wheel_diameter = 16 * global_scale;
main_gear_wheel_width = 5 * global_scale;
main_gear_oleo_stroke = 6 * global_scale;
main_gear_toe_in = 1;             // Toe-in angle (degrees)
main_gear_door = true;
main_gear_door_type = "clamshell"; // "clamshell" or "single"

// Retraction
gear_retract_angle = 90;          // Retraction angle (90 = flat into bay)
gear_retract_direction = "forward"; // "forward", "aft", "lateral"

// ============================================================
// STEALTH FEATURES
// ============================================================
// Edge alignment
align_edges = true;               // Align all edges to common angles
common_angles = [45, 35, 25, 15, 5];  // Preferred design angles (degrees)

// Sawtooth edges
sawtooth_edges = true;
sawtooth_wavelength = 8 * global_scale;
sawtooth_amplitude = 1.5 * global_scale;

// Radar absorbent material (RAM) representation
ram_panels = true;
ram_gap_treatment = true;
ram_edge_treatment = 2 * global_scale;

// ============================================================
// EXPORT SETTINGS
// ============================================================
export_stl = false;               // Set to true when rendering for export
export_assembly = true;           // Export full assembly
export_individual = false;        // Export individual parts
export_directory = "exports/";    // Export directory
stl_quality = "high";             // "low", "medium", "high", "ultra"

// Print settings reference (for documentation)
print_layer_height = 0.16;
print_infill = "10% Gyroid";
print_material = "PLA+";
print_nozzle_temp = 220;
print_bed_temp = 55;
print_supports = "tree";
print_orientation = "fuselage_down";