// ============================================================
// Stealth Fighter - Multi-Variant Commercial Print System
// ============================================================
// Baseline: original detailed aircraft
// Stealth: lighter, smoother, more print-friendly
// Hybrid: best balance of realism + fabrication
// Production: split STL-ready package for printing
// ============================================================

// ============================================================
// PROTOTYPE VARIANT + PRINT MODE
// ============================================================
prototype_variant = "hybrid";       // "baseline", "stealth", "hybrid", "production"
prototype_print_mode = "dynamic";    // "classic", "dynamic", "hybrid"
prototype_level = "custom";          // "beginner", "custom", "advanced"
prototype_print_layout = false;      // true = show multi-part print layout
prototype_support_mode = "tree";     // "tree", "linear", "none"
prototype_support_clearance = 1.5 * global_scale;
prototype_realism = "balanced";      // "baseline", "balanced", "f22_f35"

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
show_control_surfaces = true;   // Show control surface deflection

// ============================================================
// PRINTING / FABRICATION SETTINGS
// ============================================================
print_material_default = "PLA+"; // "PLA+", "PETG"
print_layer_height_pla = 0.20;
print_layer_height_petg = 0.16;
print_infill_pla = "15% Gyroid";
print_infill_petg = "12% Gyroid";
print_nozzle_temp_pla = 215;
print_nozzle_temp_petg = 240;
print_bed_temp_pla = 60;
print_bed_temp_petg = 80;
print_supports_pla = "tree";
print_supports_petg = "tree";
print_orientation_pla = "flat_wings";
print_orientation_petg = "flat_wings";
print_support_clearance = 1.5 * global_scale;

// legacy names retained for compatibility
print_layer_height = print_layer_height_pla;
print_infill = print_infill_pla;
print_material = print_material_default;
print_nozzle_temp = print_nozzle_temp_pla;
print_bed_temp = print_bed_temp_pla;
print_supports = print_supports_pla;
print_orientation = print_orientation_pla;

// ============================================================
// FUSELAGE PARAMETERS
// ============================================================
fuse_length = 180 * global_scale;
fuse_width_max = 32 * global_scale;
fuse_height_max = 24 * global_scale;

nose_length = 45 * global_scale;
nose_width_base = 18 * global_scale;
nose_height_base = 14 * global_scale;
nose_chine_angle = 35;

fwd_fuse_length = 40 * global_scale;
fwd_fuse_width = 28 * global_scale;
fwd_fuse_height = 22 * global_scale;

mid_fuse_length = 60 * global_scale;
mid_fuse_width = 32 * global_scale;
mid_fuse_height = 24 * global_scale;
mid_fuse_chine_width = 22 * global_scale;

aft_fuse_length = 35 * global_scale;
aft_fuse_width = 30 * global_scale;
aft_fuse_height = 20 * global_scale;

area_rule_waist = 0.85;
area_rule_position = 0.55;

// ============================================================
// WING PARAMETERS
// ============================================================
wing_span = 140 * global_scale;
wing_root_chord = 65 * global_scale;
wing_tip_chord = 20 * global_scale;
wing_sweep_le = 48;
wing_sweep_te = 15;
wing_dihedral = 3;
wing_twist = -2;
wing_thickness_root = 0.12;
wing_thickness_tip = 0.08;
wing_thickness_dist = "cosine";

wing_aileron_span_ratio = 0.4;
wing_aileron_chord_ratio = 0.25;
wing_flap_span_ratio = 0.35;
wing_flap_chord_ratio = 0.3;
aileron_deflection = 15;
flap_deflection = 25;

wing_root_blend = 15 * global_scale;
wing_fairing_length = 25 * global_scale;

// ============================================================
// STABILIZER PARAMETERS
// ============================================================
stab_type = "vtail";
stab_span = 60 * global_scale;
stab_root_chord = 30 * global_scale;
stab_tip_chord = 12 * global_scale;
stab_sweep_le = 45;
stab_sweep_te = 10;
stab_dihedral = 50;
stab_twist = -1;
stab_thickness_root = 0.1;
stab_thickness_tip = 0.07;

stab_all_moving = true;
stab_surface_chord_ratio = 0.35;
stab_deflection = 20;
rudder_deflection = 25;

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
canopy_position = 0.22;
canopy_stealth_coating = true;
canopy_frame_thickness = 1.5 * global_scale;
canopy_frameless = true;
canopy_bulge = 1.15;

// ============================================================
// COCKPIT PARAMETERS
// ============================================================
cockpit_floor_z = -8 * global_scale;
seat_width = 10 * global_scale;
seat_depth = 12 * global_scale;
seat_height = 18 * global_scale;
seat_recline = 18;
seat_headrest_height = 8 * global_scale;
show_ejection_details = true;
seat_handles = true;
seat_rail_height = 4 * global_scale;

panel_width = 16 * global_scale;
panel_height = 12 * global_scale;
panel_distance = 20 * global_scale;
panel_angle = 15;
hud_combiner = true;

console_width = 6 * global_scale;
console_height = 20 * global_scale;
console_depth = 8 * global_scale;

pilot_height = 35 * global_scale;
pilot_shoulder_width = 12 * global_scale;
pilot_helmet_size = 8 * global_scale;
pilot_visor_tint = true;

// ============================================================
// INTAKE / EXHAUST PARAMETERS
// ============================================================
intake_type = "dsi";
intake_position = 0.35;
intake_width = 18 * global_scale;
intake_height = 14 * global_scale;
intake_length = 50 * global_scale;
intake_capture_area = 0.025;
intake_ramp_angle = 12;
intake_bleed_doors = true;
intake_serpentine_bends = 2;
intake_duct_area_ratio = 1.3;

dsi_bump_height = 8 * global_scale;
dsi_bump_length = 30 * global_scale;
dsi_cowl_angle = 35;

exhaust_type = "2d_vectoring";
exhaust_position = 0.92;
exhaust_spacing = 16 * global_scale;
exhaust_nozzle_width = 14 * global_scale;
exhaust_nozzle_height = 6 * global_scale;
exhaust_nozzle_length = 25 * global_scale;
exhaust_thrust_vector = 15;
exhaust_serrations = 12;
exhaust_serration_depth = 3 * global_scale;
exhaust_petals = 4;
exhaust_afterburner = false;

// ============================================================
// WEAPON BAY PARAMETERS
// ============================================================
bay_position = 0.5;
bay_length = 40 * global_scale;
bay_width = 22 * global_scale;
bay_depth = 8 * global_scale;
bay_door_thickness = 1.5 * global_scale;
bay_door_angle = 85;
bay_door_chine = true;

weapon_type = "aam";
weapon_count = 4;
weapon_length = 30 * global_scale;
weapon_diameter = 3.5 * global_scale;
weapon_fin_span = 10 * global_scale;
weapon_fin_chord = 4 * global_scale;
weapon_rail_type = "launcher";

// ============================================================
// LANDING GEAR PARAMETERS
// ============================================================
gear_type = "retractable";

nose_gear_position = 0.15;
nose_gear_strut_length = 25 * global_scale;
nose_gear_wheel_diameter = 12 * global_scale;
nose_gear_wheel_width = 4 * global_scale;
nose_gear_oleo_stroke = 5 * global_scale;
nose_gear_steering = 60;
nose_gear_door = true;

main_gear_position = 0.55;
main_gear_strut_length = 22 * global_scale;
main_gear_wheel_diameter = 16 * global_scale;
main_gear_wheel_width = 5 * global_scale;
main_gear_oleo_stroke = 6 * global_scale;
main_gear_toe_in = 1;
main_gear_door = true;
main_gear_door_type = "clamshell";

gear_retract_angle = 90;
gear_retract_direction = "forward";

// ============================================================
// STEALTH FEATURES
// ============================================================
align_edges = true;
common_angles = [45, 35, 25, 15, 5];

sawtooth_edges = true;
sawtooth_wavelength = 8 * global_scale;
sawtooth_amplitude = 1.5 * global_scale;

ram_panels = true;
ram_gap_treatment = true;
ram_edge_treatment = 2 * global_scale;

// ============================================================
// EXPORT SETTINGS
// ============================================================
export_stl = false;
export_assembly = true;
export_individual = false;
export_directory = "exports/";
stl_quality = "high";

// ============================================================
// COMMERCIAL USE / FABRICATION MATRIX
// ============================================================
// baseline => detailed concept / presentation / reference
// stealth => smooth rapid prototype / easier printing
// hybrid => preferred commercial default / balanced realism + printabilty
// production => final split-part print package / manufacturing use

commercial_default_variant = "hybrid";
commercial_default_material = "PLA+";
commercial_default_support = "tree";
commercial_default_orientation = "flat_wings";
commercial_default_clearance = 1.5 * global_scale;

// ============================================================
// PRINT RECOMMENDATIONS
// ============================================================
// PLA+: 0.20mm layers, 15% gyroid, 215C nozzle, 60C bed, tree supports, flat_wings orientation
// PETG: 0.16mm layers, 12% gyroid, 240C nozzle, 80C bed, tree supports, flat_wings orientation

// ============================================================
// END OF CONFIGURATION
// ============================================================
