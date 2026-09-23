include <config.scad>

module cockpit() {
    if (!show_cockpit) return;
    
    $fn = resolution;
    
    // Cockpit position (inside canopy)
    canopy_x = -fuse_length/2 + fuse_length * canopy_position;
    canopy_z = fuse_height_max * 0.15 + fuse_height_max * 0.5;
    cockpit_z = canopy_z + cockpit_floor_z;
    
    translate([canopy_x, 0, cockpit_z]) {
        // Cockpit floor
        cockpit_floor();
        
        // Ejection seat
        ejection_seat();
        
        // Instrument panel
        instrument_panel();
        
        // HUD
        if (hud_combiner) {
            hud_combiner_glass();
        }
        
        // Side consoles
        side_consoles();
        
        // Rudder pedals
        rudder_pedals();
        
        // Pilot figure
        if (show_pilot) {
            pilot_figure();
        }
        
        // Canopy rails / canopy breakers
        canopy_rails();
    }
}

// ============================================================
// COCKPIT FLOOR
// ============================================================
module cockpit_floor() {
    floor_len = canopy_length * 0.85;
    floor_w = canopy_width_max * 0.7;
    floor_thick = 3 * global_scale;
    
    // Main floor
    translate([canopy_length * 0.075, 0, -floor_thick/2])
    cube([floor_len, floor_w, floor_thick], center=true);
    
    // Foot wells (cutouts for rudder pedals)
    translate([canopy_length * 0.15, 0, floor_thick/2])
    cube([canopy_length * 0.25, panel_width * 0.5, floor_thick * 2], center=true);
}

// ============================================================
// EJECTION SEAT (ACES II / Martin-Baker style)
// ============================================================
module ejection_seat() {
    // Seat position
    seat_x = canopy_length * 0.25;
    seat_y = 0;
    seat_z = 0;
    
    translate([seat_x, seat_y, seat_z]) {
        // Seat pan
        seat_pan();
        
        // Seat back with headrest
        seat_back();
        
        // Side structures / catapult beams
        if (show_ejection_details) {
            ejection_mechanism();
        }
        
        // Armrests / side consoles integration
        seat_armrests();
        
        // Seat adjustment rails
        seat_rails();
        
        // Parachute container (aft)
        parachute_container();
        
        // Survival kit (under seat)
        survival_kit();
        
        // Harness / restraint system
        restraint_system();
    }
}

module seat_pan() {
    // Seat bottom cushion and structure
    pan_w = seat_width;
    pan_d = seat_depth;
    pan_h = 4 * global_scale;
    
    // Cushion
    color("gray", 0.8) {
        translate([0, 0, pan_h/2])
        scale([pan_w, pan_d, pan_h])
        sphere(1);
    }
    
    // Seat pan structure (metal)
    color("darkgray") {
        translate([0, 0, -pan_h/2])
        cube([pan_w * 0.9, pan_d * 0.9, pan_h], center=true);
        
        // Front lip
        translate([pan_w * 0.45, 0, 0])
        cube([pan_w * 0.1, pan_d * 0.9, pan_h * 1.5], center=true);
    }
}

module seat_back() {
    back_w = seat_width;
    back_h = seat_height;
    back_d = 3 * global_scale;
    
    // Seat back cushion
    color("gray", 0.8) {
        translate([-back_d/2 - 1, 0, back_h/2])
        rotate([0, -seat_recline, 0])
        scale([back_d, back_w, back_h])
        sphere(1);
    }
    
    // Seat back structure
    color("darkgray") {
        translate([-back_d - 2, 0, back_h/2])
        rotate([0, -seat_recline, 0])
        cube([back_d * 2, back_w * 0.9, back_h * 0.9], center=true);
    }
    
    // Headrest
    if (seat_headrest_height > 0) {
        color("gray", 0.9) {
            translate([-back_d - 2, 0, back_h + seat_headrest_height/2])
            rotate([0, -seat_recline, 0])
            scale([back_d * 1.5, back_w * 0.7, seat_headrest_height])
            sphere(1);
        }
    }
    
    // Lumbar support
    color("gray", 0.7) {
        translate([-back_d/2 - 2, 0, back_h * 0.3])
        rotate([0, -seat_recline, 0])
        scale([back_d, back_w * 0.5, back_h * 0.2])
        sphere(1);
    }
}

module ejection_mechanism() {
    // Catapult beams (side rails that guide seat during ejection)
    beam_h = seat_height + 10 * global_scale;
    beam_w = 4 * global_scale;
    beam_d = 2 * global_scale;
    
    color("darkgray") {
        for (side = [-1, 1]) {
            translate([seat_width/2 * side + beam_w/2 * side, 0, beam_h/2])
            cube([beam_w, beam_d, beam_h], center=true);
            
            // Top handle (ejection trigger)
            if (seat_handles) {
                translate([seat_width/2 * side + beam_w/2 * side, seat_depth * 0.3 * side, beam_h * 0.9])
                rotate([0, 90, 0])
                cylinder(h = 8 * global_scale, r = 1.5 * global_scale, center=true);
            }
        }
    }
    
    // Drogue gun (top of seat)
    color("darkgray") {
        translate([0, 0, seat_height + 5 * global_scale])
        cylinder(h = 6 * global_scale, r = 2 * global_scale, center=true);
    }
    
    // Stabilization streamer / rocket motor
    color("red", 0.8) {
        translate([0, -seat_depth/2 - 3, seat_height * 0.6])
        cylinder(h = 12 * global_scale, r = 1.5 * global_scale, center=true);
    }
}

module seat_armrests() {
    // Armrests on seat sides
    arm_w = 3 * global_scale;
    arm_l = seat_depth * 0.6;
    arm_h = 2 * global_scale;
    
    color("gray", 0.7) {
        for (side = [-1, 1]) {
            translate([seat_width/2 * side + arm_w/2 * side, seat_depth * 0.1 * side, seat_height * 0.2])
            cube([arm_w, arm_l, arm_h], center=true);
            
            // Armrest adjustment
            if (show_ejection_details) {
                translate([seat_width/2 * side + arm_w/2 * side, seat_depth * 0.4 * side, seat_height * 0.2])
                cylinder(h = arm_h, r = 1 * global_scale, center=true);
            }
        }
    }
}

module seat_rails() {
    // Seat adjustment rails on floor
    rail_len = seat_depth * 1.5;
    rail_w = 2 * global_scale;
    rail_h = seat_rail_height;
    
    color("darkgray") {
        for (side = [-1, 1]) {
            translate([seat_x - rail_len/2, seat_width/2 * side + rail_w/2 * side, rail_h/2])
            cube([rail_len, rail_w, rail_h], center=true);
            
            // Locking pins
            for (i = [0 : 3]) {
                translate([seat_x - rail_len/2 + rail_len * i / 3, seat_width/2 * side + rail_w/2 * side, rail_h + 1])
                cylinder(h = 3, r = 1, center=true);
            }
        }
    }
}

module parachute_container() {
    // Parachute container at top rear of seat
    color("olive", 0.8) {
        translate([-seat_depth * 0.3, 0, seat_height + seat_headrest_height + 5 * global_scale])
        scale([seat_width * 0.8, seat_width * 0.4, 10 * global_scale])
        sphere(1);
    }
    
    // Ripcord handle
    if (seat_handles) {
        color("yellow") {
            translate([-seat_depth * 0.4, 0, seat_height + seat_headrest_height + 10 * global_scale])
            rotate([90, 0, 0])
            cylinder(h = 6 * global_scale, r = 1 * global_scale, center=true);
        }
    }
}

module survival_kit() {
    // Survival kit under seat pan
    color("olive", 0.7) {
        translate([0, 0, -6 * global_scale])
        cube([seat_width * 0.8, seat_depth * 0.7, 8 * global_scale], center=true);
    }
}

module restraint_system() {
    // 5-point harness
    color("black") {
        // Shoulder straps
        for (side = [-1, 1]) {
            // From shoulder to buckle
            hull() {
                translate([seat_width/2 * 0.7 * side, -seat_depth * 0.2, seat_height * 0.8])
                sphere(1.5 * global_scale);
                
                translate([0, seat_depth * 0.3, seat_height * 0.1])
                sphere(1.5 * global_scale);
            }
        }
        
        // Lap belt
        hull() {
            translate([-seat_width/2 * 0.8, seat_depth * 0.4, seat_height * 0.1])
            sphere(1.5 * global_scale);
            
            translate([seat_width/2 * 0.8, seat_depth * 0.4, seat_height * 0.1])
            sphere(1.5 * global_scale);
        }
        
        // Crotch strap
        hull() {
            translate([0, seat_depth * 0.4, seat_height * 0.1])
            sphere(1.5 * global_scale);
            
            translate([0, 0, -seat_height * 0.2])
            sphere(1.5 * global_scale);
        }
    }
    
    // Quick-release buckle
    color("gold") {
        translate([0, seat_depth * 0.35, seat_height * 0.1])
        cube([6 * global_scale, 4 * global_scale, 3 * global_scale], center=true);
    }
}

// ============================================================
// INSTRUMENT PANEL
// ============================================================
module instrument_panel() {
    panel_x = canopy_length * 0.08;
    panel_z = panel_height/2;
    
    translate([panel_x, 0, panel_z]) {
        // Panel structure
        color("black") {
            rotate([0, -panel_angle, 0])
            cube([panel_width, panel_width * 0.1, panel_height], center=true);
        }
        
        // MFDs (Multi-Function Displays)
        mfd_count = 3;
        mfd_w = panel_width / mfd_count * 0.8;
        mfd_h = panel_height * 0.7;
        mfd_spacing = panel_width / mfd_count;
        
        for (i = [0 : mfd_count - 1]) {
            let(x_pos = -panel_width/2 + mfd_spacing/2 + mfd_spacing * i) {
                // MFD bezel
                color("darkgray") {
                    translate([x_pos, panel_width * 0.06, 0])
                    rotate([0, -panel_angle, 0])
                    cube([mfd_w * 1.05, panel_width * 0.08, mfd_h * 1.05], center=true);
                }
                
                // MFD screen
                color("blue", 0.3) {
                    translate([x_pos, panel_width * 0.07, 0])
                    rotate([0, -panel_angle, 0])
                    cube([mfd_w, panel_width * 0.02, mfd_h], center=true);
                }
                
                // MFD buttons (side)
                color("gray") {
                    for (btn = [0 : 7]) {
                        translate([x_pos + mfd_w/2 + 2, panel_width * 0.07, mfd_h/2 - mfd_h * btn / 8])
                        rotate([0, -panel_angle, 0])
                        cube([3, 3, mfd_h / 10], center=true);
                    }
                }
            }
        }
        
        // Center standby instruments (analog backup)
        color("black") {
            translate([0, panel_width * 0.06, -panel_height/2 + 10])
            rotate([0, -panel_angle, 0])
            cube([panel_width * 0.15, panel_width * 0.08, 20], center=true);
        }
        
        // Warning/caution lights panel (top)
        color("darkred") {
            translate([0, panel_width * 0.06, panel_height/2 - 5])
            rotate([0, -panel_angle, 0])
            cube([panel_width * 0.9, panel_width * 0.08, 10], center=true);
        }
        
        // Light indicators
        for (i = [0 : 12]) {
            let(x_pos = -panel_width/2 + 10 + panel_width * 0.9 * i / 12) {
                color(i % 3 == 0 ? "red" : i % 3 == 1 ? "yellow" : "green") {
                    translate([x_pos, panel_width * 0.07, panel_height/2 - 5])
                    rotate([0, -panel_angle, 0])
                    cylinder(h = 2, r = 1.5, center=true);
                }
            }
        }
    }
}

module hud_combiner_glass() {
    // HUD combiner glass (angled at pilot eye level)
    hud_x = panel_x - 5;
    hud_z = panel_height * 0.3;
    hud_w = panel_width * 0.9;
    hud_h = panel_height * 0.5;
    hud_thick = 3 * global_scale;
    
    // Combiner glass
    color("green", 0.1) {
        translate([hud_x, 0, hud_z])
        rotate([0, -panel_angle - 15, 0])
        cube([hud_thick, hud_w, hud_h], center=true);
    }
    
    // HUD projector unit (on dashboard)
    color("darkgray") {
        translate([hud_x - 15, 0, hud_z - hud_h/2 - 5])
        cube([12, hud_w * 0.3, 10], center=true);
    }
    
    // HUD symbology (representative)
    color("green", 0.8) {
        // Velocity ladder (left)
        for (i = [0 : 10]) {
            translate([hud_x - hud_w/2 + 5, -hud_w/2 + 5 + hud_w * i / 10, hud_z])
            rotate([0, -panel_angle - 15, 0])
            cube([hud_thick + 1, 2, 1], center=true);
        }
        
        // Altitude tape (right)
        for (i = [0 : 10]) {
            translate([hud_x + hud_w/2 - 5, -hud_w/2 + 5 + hud_w * i / 10, hud_z])
            rotate([0, -panel_angle - 15, 0])
            cube([hud_thick + 1, 2, 1], center=true);
        }
        
        // Horizon line
        translate([hud_x, 0, hud_z])
        rotate([0, -panel_angle - 15, 0])
        cube([hud_thick + 1, hud_w * 0.8, 1], center=true);
        
        // Flight path marker (circle with wings)
        translate([hud_x, 0, hud_z])
        rotate([0, -panel_angle - 15, 0])
        circle_hud(8);
    }
}

module circle_hud(r) {
    // Simple circle approximation for HUD
    n = 32;
    points = [for (i = [0 : n - 1]) [r * cos(360 * i / n), r * sin(360 * i / n)]];
    linear_extrude(height = 1)
    polygon(points);
}

// ============================================================
// SIDE CONSOLES
// ============================================================
module side_consoles() {
    console_x_start = canopy_length * 0.1;
    console_x_end = canopy_length * 0.6;
    console_z = console_height/2;
    
    for (side = [-1, 1]) {
        translate([console_x_start + (console_x_end - console_x_start)/2, side * (canopy_width_max * 0.35 + console_width/2), console_z]) {
            // Main console structure
            color("black") {
                cube([console_x_end - console_x_start, console_width, console_height], center=true);
            }
            
            // Throttle quadrant (left console)
            if (side == -1) {
                throttle_quadrant();
            }
            
            // Avionics/weapon controls (right console)
            if (side == 1) {
                avionics_panel();
            }
            
            // Switch panels
            switch_panels(side);
        }
    }
}

module throttle_quadrant() {
    // Throttle levers
    color("black") {
        // Base
        translate([0, -console_width/2 + 5, -console_height/2 + 10])
        cube([8, 10, 20], center=true);
        
        // Throttle levers (2 for twin engine)
        for (i = [-1, 1]) {
            translate([0, -console_width/2 + 5 + i * 4, -console_height/2 + 25])
            rotate([-15, 0, 0])
            cylinder(h = 30, r = 1.5, center=true);
            
            // Throttle grip
            color("gray") {
                translate([0, -console_width/2 + 5 + i * 4, -console_height/2 + 40])
                sphere(3);
            }
        }
    }
}

module avionics_panel() {
    // Avionics control panel
    color("black") {
        // Button grid
        rows = 4;
        cols = 3;
        btn_size = 6;
        spacing = 8;
        
        for (r = [0 : rows - 1]) {
            for (c = [0 : cols - 1]) {
                let(x_pos = -console_width/2 + 5 + c * spacing,
                    z_pos = console_height/2 - 10 - r * spacing) {
                    color("gray") {
                        translate([x_pos, console_width/2 - 3, z_pos])
                        cube([btn_size, 4, btn_size], center=true);
                    }
                    
                    // LED indicator
                    color(r % 2 == 0 ? "green" : "amber") {
                        translate([x_pos, console_width/2 - 1, z_pos + btn_size/2 - 1])
                        cylinder(h = 2, r = 1, center=true);
                    }
                }
            }
        }
    }
}

module switch_panels(side) {
    // Toggle switch panels
    color("darkgray") {
        for (i = [0 : 5]) {
            let(z_pos = -console_height/2 + 10 + i * 12) {
                // Switch guard
                translate([console_x_end - console_x_start - 10, side * console_width/2 * 0.8, z_pos])
                cube([4, 8, 8], center=true);
                
                // Toggle
                color("red") {
                    translate([console_x_end - console_x_start - 10, side * console_width/2 * 0.8, z_pos + 5])
                    rotate([90, 0, 0])
                    cylinder(h = 6, r = 1, center=true);
                }
            }
        }
    }
}

// ============================================================
// RUDDER PEDALS
// ============================================================
module rudder_pedals() {
    pedal_x = canopy_length * 0.12;
    pedal_z = -5 * global_scale;  // Below floor
    
    translate([pedal_x, 0, pedal_z]) {
        color("darkgray") {
            // Pedal arms
            for (side = [-1, 1]) {
                // Arm
                translate([0, side * 8, 0])
                rotate([0, 0, side * 15])  // Slight angle
                cube([canopy_length * 0.1, 2, 15 * global_scale], center=true);
                
                // Pedal plate
                translate([canopy_length * 0.05, side * 8, 15 * global_scale/2])
                rotate([0, 0, side * 15])
                cube([6, 10, 2], center=true);
                
                // Toe brake
                translate([canopy_length * 0.08, side * 8, 15 * global_scale/2 + 5])
                rotate([0, 0, side * 15])
                cube([3, 8, 3], center=true);
            }
            
            // Center support
            translate([canopy_length * 0.05, 0, 7 * global_scale])
            cylinder(h = 14 * global_scale, r = 1.5 * global_scale, center=true);
        }
    }
}

// ============================================================
// PILOT FIGURE
// ============================================================
module pilot_figure() {
    // Pilot seated in ejection seat
    pilot_z = seat_height * 0.6;  // Sitting height
    
    translate([seat_x, 0, pilot_z]) {
        // Helmet
        helmet();
        
        // Head
        head();
        
        // Torso
        torso();
        
        // Arms (on armrests / controls)
        arms();
        
        // Legs (on rudder pedals)
        legs();
        
        // Oxygen hose
        oxygen_hose();
        
        // Ejection seat connections
        seat_connections();
    }
}

module helmet() {
    helmet_r = pilot_helmet_size;
    helmet_h = pilot_helmet_size * 1.3;
    
    // Helmet shell
    color("gray", 0.9) {
        translate([0, 0, helmet_h/2])
        scale([1, 1.1, 1.2])
        sphere(helmet_r);
    }
    
    // Visor
    if (pilot_visor_tint) {
        color("gold", 0.5) {
            translate([helmet_r * 0.3, 0, 0])
            scale([helmet_r * 0.8, helmet_r * 1.0, helmet_h * 0.6])
            sphere(1);
        }
    } else {
        color("clear", 0.3) {
            translate([helmet_r * 0.3, 0, 0])
            scale([helmet_r * 0.8, helmet_r * 1.0, helmet_h * 0.6])
            sphere(1);
        }
    }
    
    // Helmet details (NVG mount, comms)
    color("black") {
        // NVG mount
        translate([0, 0, helmet_h * 0.8])
        cylinder(h = 3 * global_scale, r = 2 * global_scale, center=true);
        
        // Oxygen mask connector
        translate([helmet_r * 0.8, 0, helmet_h * 0.2])
        cylinder(h = 4 * global_scale, r = 1.5 * global_scale, center=true);
    }
}

module head() {
    // Head inside helmet (simplified)
    color("peach") {
        translate([0, 0, pilot_helmet_size * 0.4])
        sphere(pilot_helmet_size * 0.7);
    }
}

module torso() {
    torso_h = pilot_height * 0.5;
    torso_w = pilot_shoulder_width;
    torso_d = pilot_shoulder_width * 0.6;
    
    // Flight suit
    color("olive", 0.9) {
        translate([0, 0, torso_h/2])
        scale([torso_d, torso_w, torso_h])
        sphere(1);
    }
    
    // G-suit bladders (legs/lower torso)
    color("darkgreen", 0.7) {
        translate([0, 0, torso_h * 0.2])
        scale([torso_d * 1.05, torso_w * 1.05, torso_h * 0.5])
        sphere(1);
    }
    
    // Survival vest
    color("olive", 0.8) {
        translate([0, 0, torso_h * 0.6])
        scale([torso_d * 1.1, torso_w * 1.1, torso_h * 0.4])
        sphere(1);
    }
}

module arms() {
    upper_arm_len = pilot_height * 0.18;
    forearm_len = pilot_height * 0.16;
    arm_dia = 3 * global_scale;
    
    color("olive", 0.9) {
        for (side = [-1, 1]) {
            // Shoulder
            translate([side * pilot_shoulder_width/2, 0, pilot_height * 0.35])
            sphere(arm_dia * 1.5);
            
            // Upper arm (resting on armrest)
            translate([side * (pilot_shoulder_width/2 + upper_arm_len/2), 0, pilot_height * 0.25])
            rotate([0, 90, side * -20])
            cylinder(h = upper_arm_len, r = arm_dia, center=true);
            
            // Elbow
            translate([side * (pilot_shoulder_width/2 + upper_arm_len), 0, pilot_height * 0.25])
            sphere(arm_dia * 1.2);
            
            // Forearm (toward stick/throttle)
            translate([side * (pilot_shoulder_width/2 + upper_arm_len + forearm_len/2 * 0.7), 
                       side * forearm_len/2 * 0.7, pilot_height * 0.2])
            rotate([0, 45, side * -60])
            cylinder(h = forearm_len, r = arm_dia * 0.8, center=true);
            
            // Hand
            translate([side * (pilot_shoulder_width/2 + upper_arm_len + forearm_len * 0.7), 
                       side * forearm_len * 0.7, pilot_height * 0.15])
            sphere(arm_dia * 1.3);
        }
    }
}

module legs() {
    thigh_len = pilot_height * 0.22;
    shin_len = pilot_height * 0.2;
    leg_dia = 3.5 * global_scale;
    
    color("olive", 0.9) {
        for (side = [-1, 1]) {
            // Hip
            translate([side * pilot_shoulder_width * 0.3, 0, pilot_height * 0.05])
            sphere(leg_dia * 1.5);
            
            // Thigh (down to knee)
            translate([side * pilot_shoulder_width * 0.3, 0, -thigh_len/2])
            cylinder(h = thigh_len, r = leg_dia, center=true);
            
            // Knee
            translate([side * pilot_shoulder_width * 0.3, 0, -thigh_len])
            sphere(leg_dia * 1.3);
            
            // Shin (forward to rudder pedals)
            translate([side * pilot_shoulder_width * 0.3 + shin_len/2 * 0.5, 0, -thigh_len - shin_len/2])
            rotate([-50, 0, 0])
            cylinder(h = shin_len, r = leg_dia * 0.8, center=true);
            
            // Foot on pedal
            translate([side * pilot_shoulder_width * 0.3 + shin_len * 0.5, 0, -thigh_len - shin_len])
            rotate([-50, 0, 0])
            cube([6, 10, 3], center=true);
        }
    }
}

module oxygen_hose() {
    // Oxygen hose from console to mask
    color("gray", 0.7) {
        // Hose from right console
        hull() {
            translate([canopy_length * 0.35, canopy_width_max * 0.35, console_height * 0.5])
            sphere(2);
            
            translate([seat_x + pilot_helmet_size, 0, pilot_helmet_size * 0.5])
            sphere(2);
        }
    }
}

module seat_connections() {
    // Seat-to-pilot connections (harness, oxygen, comms)
    color("black") {
        // Harness connections to seat
        for (side = [-1, 1]) {
            // Shoulder strap to seat
            hull() {
                translate([side * pilot_shoulder_width * 0.6, -seat_depth * 0.1, pilot_height * 0.35])
                sphere(1.5);
                
                translate([side * seat_width/2, -seat_depth * 0.3, seat_height * 0.8])
                sphere(1.5);
            }
            
            // Lap belt connection
            hull() {
                translate([side * pilot_shoulder_width * 0.4, seat_depth * 0.3, pilot_height * 0.1])
                sphere(1.5);
                
                translate([side * seat_width/2, seat_depth * 0.4, seat_height * 0.1])
                sphere(1.5);
            }
        }
    }
}

module canopy_rails() {
    // Canopy guide rails / breakers
    color("darkgray") {
        for (side = [-1, 1]) {
            // Forward rail
            translate([canopy_length * 0.05, side * canopy_width_max * 0.55, canopy_height_max * 0.2])
            rotate([0, 90, 0])
            cylinder(h = canopy_width_max * 1.1, r = 2 * global_scale, center=true);
            
            // Aft rail
            translate([canopy_length * 0.85, side * canopy_width_max * 0.55, canopy_height_max * 0.2])
            rotate([0, 90, 0])
            cylinder(h = canopy_width_max * 1.1, r = 2 * global_scale, center=true);
        }
    }
}

// For standalone preview
cockpit();