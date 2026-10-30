// ============================================================
// DYNAMIX / PROTOTYPE MODE CONFIGURATION
// ============================================================
prototype_variant = "hybrid";       // "baseline", "stealth", "hybrid", "production"
prototype_print_mode = "dynamic";   // "classic", "dynamic", "hybrid"
prototype_level = "custom";         // "beginner", "custom", "advanced"
prototype_print_layout = false;      // true = show multi-part print layout
prototype_support_mode = "tree";     // "tree", "linear", "none"
prototype_support_clearance = 1.5 * global_scale;
prototype_realism = "balanced";     // "baseline", "balanced", "f22_f35"

// Legacy compatibility variables
print_optimized = false;
print_optimized_variant = prototype_variant;
print_material_default = "PLA+";
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
print_material = print_material_default;
print_layer_height = print_layer_height_pla;
print_infill = print_infill_pla;
print_nozzle_temp = print_nozzle_temp_pla;
print_bed_temp = print_bed_temp_pla;
print_supports = print_supports_pla;
print_orientation = print_orientation_pla;
