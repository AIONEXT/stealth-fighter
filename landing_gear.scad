include <config.scad>

module wheel() {
    // Detailed wheel with tire and hub
    difference() {
        // Tire
        color("black") {
            cylinder(h = 4 * global_scale, r = 5 * global_scale, center=true);
        }
        
        // Hub bore
        color("silver") {
            translate([0, 0, -2.5 * global_scale])
            cylinder(h = 5 * global_scale, r = 1.5 * global_scale, center=true);
        }
    }
    
    // Wheel hub detail
    color("silver") {
        // Hub center
        translate([0, 0, 0])
        cylinder(h = 4.5 * global_scale, r = 2 * global_scale, center=true);
        
        // Bolt pattern
        for (i = [0 : 4]) {
            rotate([0, 0, i * 72])
            translate([3.5 * global_scale, 0, 0])
            cylinder(h = 5 * global_scale, r = 0.5 * global_scale, center=true);
        }
    }
    
    // Brake rotor (main gear)
    // color("darkred") { ... }
}

module landing_gear() {
    if (!show_landing_gear) return;
    
    $fn = resolution;
    
    if (gear_type == "retractable") {
        retractable_gear();
    } else {
        fixed_gear();
    }
}

// ============================================================
// RETRACTABLE LANDING GEAR
// ============================================================
module retractable_gear() {
    if (show_gear_down) {
        // Gear deployed (down)
        nose_gear_deployed();
        main_gear_deployed();
    } else {
        // Gear retracted (up)
        nose_gear_retracted();
        main_gear_retracted();
    }
    
    // Gear doors (always shown for reference)
    if (nose_gear_door) nose_gear_door_mechanism();
    if (main_gear_door) main_gear_door_mechanism();
}

// ============================================================
// NOSE GEAR - DEPLOYED
// ============================================================
module nose_gear_deployed() {
    // Position at fuselage
    gear_x = -fuse_length/2 + fuse_length * nose_gear_position;
    gear_z = -fuse_height_max/2;
    
    translate([gear_x, 0, gear_z]) {
        // Oleo strut (shock absorber)
        oleo_strut(nose_gear_strut_length, nose_gear_oleo_stroke, "nose");
        
        // Wheel assembly
        translate([0, 0, -nose_gear_strut_length + nose_gear_oleo_stroke])
        nose_wheel_assembly();
        
        // Steering mechanism
        if (nose_gear_steering > 0) {
            nose_steering_mechanism();
        }
        
        // Torque links (scissors)
        torque_links("nose");
        
        // Hydraulic lines
        gear_hydraulics("nose");
    }
}

module nose_gear_retracted() {
    // Gear stowed in bay
    gear_x = -fuse_length/2 + fuse_length * nose_gear_position;
    gear_z = -fuse_height_max/2;
    
    translate([gear_x, 0, gear_z]) {
        // Strut rotated up into bay
        rotate([0, -gear_retract_angle, 0]) {
            oleo_strut(nose_gear_strut_length, 0, "nose");
            
            // Wheel stowed
            translate([0, 0, -nose_gear_strut_length])
            nose_wheel_assembly();
        }
    }
}

module nose_wheel_assembly() {
    // Wheel with fork
    fork_w = 6 * global_scale;
    fork_l = 8 * global_scale;
    
    color("darkgray") {
        // Fork (two arms)
        for (side = [-1, 1]) {
            translate([side * fork_w/2, 0, -fork_l/2])
            cube([fork_w * 0.5, 2 * global_scale, fork_l], center=true);
        }
        
        // Fork crown (top)
        translate([0, 0, fork_l/2])
        cube([fork_w * 1.5, 3 * global_scale, 3 * global_scale], center=true);
        
        // Axle
        translate([0, 0, -fork_l/2])
        rotate([0, 90, 0])
        cylinder(h = fork_w * 1.2, r = 1 * global_scale, center=true);
    }
    
    // Wheel
    translate([0, 0, -fork_l/2 - 2 * global_scale])
    wheel();
    
    // Mudguard
    nose_mudguard();
}

module nose_mudguard() {
    // Small mudguard over nose wheel
    color("darkgray") {
        translate([0, 0, -10 * global_scale])
        scale([12 * global_scale, 10 * global_scale, 4 * global_scale])
        sphere(1);
    }
}

module nose_steering_mechanism() {
    // Steering actuator and linkage
    color("darkgray") {
        // Actuator cylinder
        translate([-6 * global_scale, 0, -nose_gear_strut_length/2])
        rotate([0, 90, 0])
        cylinder(h = 12 * global_scale, r = 1.5 * global_scale, center=true);
        
        // Steering arm
        translate([-2 * global_scale, 0, -nose_gear_strut_length + 5 * global_scale])
        cube([4 * global_scale, 2 * global_scale, 10 * global_scale], center=true);
    }
}

// ============================================================
// MAIN GEAR - DEPLOYED
// ============================================================
module main_gear_deployed() {
    gear_x = -fuse_length/2 + fuse_length * main_gear_position;
    gear_z = -fuse_height_max/2;
    
    for (side = [-1, 1]) {
        let(y_pos = side * (fuse_width_max/2 + 5)) {
            translate([gear_x, y_pos, gear_z]) {
                // Main gear strut (angled slightly)
                rotate([0, side * -5, 0]) {  // Slight outward cant
                    main_oleo_strut(main_gear_strut_length, main_gear_oleo_stroke);
                }
                
                // Wheel truck (2 wheels for heavy fighter)
                main_wheel_truck(side);
                
                // Torque links
                torque_links("main");
                
                // Brake system
                main_brake_system(side);
                
                // Hydraulics
                gear_hydraulics("main");
                
                // Gear door linkage
                if (main_gear_door) {
                    main_door_linkage(side);
                }
            }
        }
    }
}

module main_gear_retracted() {
    gear_x = -fuse_length/2 + fuse_length * main_gear_position;
    gear_z = -fuse_height_max/2;
    
    for (side = [-1, 1]) {
        let(y_pos = side * (fuse_width_max/2 + 5)) {
            translate([gear_x, y_pos, gear_z]) {
                // Retracted position
                if (gear_retract_direction == "forward") {
                    rotate([0, -gear_retract_angle, 0]) {
                        main_oleo_strut(main_gear_strut_length, 0);
                        translate([0, 0, -main_gear_strut_length])
                        main_wheel_truck(side);
                    }
                } else if (gear_retract_direction == "aft") {
                    rotate([0, gear_retract_angle, 0]) {
                        main_oleo_strut(main_gear_strut_length, 0);
                        translate([0, 0, -main_gear_strut_length])
                        main_wheel_truck(side);
                    }
                } else {
                    // Lateral retraction
                    rotate([gear_retract_angle * side, 0, 0]) {
                        main_oleo_strut(main_gear_strut_length, 0);
                        translate([0, 0, -main_gear_strut_length])
                        main_wheel_truck(side);
                    }
                }
            }
        }
    }
}

module main_oleo_strut(strut_len, stroke) {
    // Main gear oleo-pneumatic strut (two-stage)
    upper_len = strut_len * 0.6;
    lower_len = strut_len * 0.4;
    
    color("darkgray") {
        // Upper cylinder (outer)
        translate([0, 0, -upper_len/2])
        cylinder(h = upper_len, r = 2.5 * global_scale, center=true);
        
        // Lower cylinder (inner - slides)
        translate([0, 0, -upper_len - lower_len/2 + stroke])
        cylinder(h = lower_len, r = 2 * global_scale, center=true);
        
        // Servicing valve
        translate([3 * global_scale, 0, -upper_len/2])
        cylinder(h = 3 * global_scale, r = 0.8 * global_scale, center=true);
        
        // Strut fairing (aerodynamic cover)
        strut_fairing(strut_len);
    }
}

module strut_fairing(strut_len) {
    // Aerodynamic fairing on strut
    color("darkgray", 0.7) {
        translate([0, 0, -strut_len/2])
        scale([3 * global_scale, 6 * global_scale, strut_len])
        sphere(1);
    }
}

module main_wheel_truck(side) {
    // Two-wheel bogie for main gear
    wheel_spacing = 14 * global_scale;
    truck_beam_len = wheel_spacing + 10 * global_scale;
    truck_beam_w = 4 * global_scale;
    truck_beam_h = 3 * global_scale;
    
    color("darkgray") {
        // Truck beam
        translate([0, 0, -main_gear_strut_length + main_gear_oleo_stroke - truck_beam_h/2])
        cube([truck_beam_len, truck_beam_w, truck_beam_h], center=true);
        
        // Wheel axles
        for (w = [-1, 1]) {
            let(y_pos = w * wheel_spacing/2) {
                // Axle housing
                translate([y_pos, 0, -truck_beam_h/2 - 3 * global_scale])
                rotate([0, 90, 0])
                cylinder(h = truck_beam_w * 1.5, r = 2 * global_scale, center=true);
                
                // Wheel
                translate([y_pos, 0, -truck_beam_h/2 - 5 * global_scale])
                wheel();
                
                // Brake caliper
                main_brake_caliper(y_pos);
            }
        }
        
        // Trunnion (attachment to strut)
        truck_trunnion();
    }
}

module truck_trunnion() {
    // Trunnion bearing for gear retraction
    color("steelblue") {
        translate([0, 0, 3 * global_scale])
        cylinder(h = 6 * global_scale, r = 2.5 * global_scale, center=true);
        
        // Trunnion pin
        color("silver") {
            translate([0, 0, 6 * global_scale])
            rotate([0, 90, 0])
            cylinder(h = 10 * global_scale, r = 1.5 * global_scale, center=true);
        }
    }
}

module main_brake_caliper(y_pos) {
    // Brake caliper (disc brake)
    color("darkred", 0.8) {
        translate([y_pos, 6 * global_scale, -5 * global_scale])
        cube([8 * global_scale, 3 * global_scale, 6 * global_scale], center=true);
        
        // Brake pistons
        for (i = [0 : 3]) {
            translate([y_pos + 4 * global_scale - i * 2.5 * global_scale, 7 * global_scale, -5 * global_scale])
            cylinder(h = 4 * global_scale, r = 0.8 * global_scale, center=true);
        }
    }
    
    // Brake rotor (on wheel hub)
    color("darkgray") {
        translate([y_pos, 0, -5 * global_scale])
        rotate([0, 90, 0])
        difference() {
            cylinder(h = 1.5 * global_scale, r = 4.5 * global_scale, center=true);
            cylinder(h = 2 * global_scale, r = 1.5 * global_scale, center=true);
        }
    }
}

module main_brake_system(side) {
    // Anti-skid control box
    color("darkgray") {
        translate([-10 * global_scale, side * 5 * global_scale, -main_gear_strut_length/2])
        cube([8 * global_scale, 4 * global_scale, 6 * global_scale], center=true);
    }
    
    // Brake hydraulic lines
    color("blue", 0.5) {
        translate([0, 0, -main_gear_strut_length + main_gear_oleo_stroke - 5 * global_scale])
        cylinder(h = main_gear_strut_length, r = 1 * global_scale, center=true);
    }
}

// ============================================================
// TORQUE LINKS (SCISSORS) - Prevent strut rotation
// ============================================================
module torque_links(gear_type) {
    // Scissor links between upper and lower strut
    link_len = (gear_type == "nose") ? nose_gear_strut_length * 0.3 : main_gear_strut_length * 0.3;
    link_w = 2 * global_scale;
    link_thick = 1 * global_scale;
    
    color("steelblue") {
        // Upper link
        translate([0, 0, -(gear_type == "nose" ? nose_gear_strut_length : main_gear_strut_length) * 0.7])
        rotate([0, 30, 0])
        cube([link_len, link_w, link_thick], center=true);
        
        // Lower link
        translate([0, 0, -(gear_type == "nose" ? nose_gear_strut_length : main_gear_strut_length) * 0.7])
        rotate([0, -30, 0])
        cube([link_len, link_w, link_thick], center=true);
        
        // Pivot points
        for (side = [-1, 1]) {
            translate([side * link_len/2, 0, -(gear_type == "nose" ? nose_gear_strut_length : main_gear_strut_length) * 0.7])
            sphere(1.5 * global_scale);
        }
    }
}

// ============================================================
// GEAR HYDRAULICS
// ============================================================
module gear_hydraulics(gear_type) {
    // Hydraulic lines for gear extension/retraction
    color("blue", 0.4) {
        // Main hydraulic line
        strut_len = (gear_type == "nose") ? nose_gear_strut_length : main_gear_strut_length;
        
        translate([3 * global_scale, 2 * global_scale, -strut_len/2])
        cylinder(h = strut_len, r = 0.8 * global_scale, center=true);
        
        // Return line
        translate([-3 * global_scale, 2 * global_scale, -strut_len/2])
        cylinder(h = strut_len, r = 0.8 * global_scale, center=true);
    }
    
    // Actuator for retraction
    color("darkgray") {
        translate([0, -5 * global_scale, -strut_len * 0.3])
        rotate([0, 90, 0])
        cylinder(h = 15 * global_scale, r = 2 * global_scale, center=true);
    }
}

// ============================================================
// GEAR DOORS
// ============================================================
module nose_gear_door_mechanism() {
    // Nose gear doors (typically two doors that close after gear retracts)
    door_len = nose_gear_strut_length + 10 * global_scale;
    door_w = 10 * global_scale;
    door_h = 12 * global_scale;
    
    gear_x = -fuse_length/2 + fuse_length * nose_gear_position;
    gear_z = -fuse_height_max/2;
    
    translate([gear_x, 0, gear_z]) {
        if (show_gear_down) {
            // Doors open
            nose_gear_doors_open(door_len, door_w, door_h);
        } else {
            // Doors closed
            nose_gear_doors_closed(door_len, door_w, door_h);
        }
    }
}

module nose_gear_doors_open(len, w, h) {
    // Two doors hinged at sides
    for (side = [-1, 1]) {
        rotate([0, side * -85, 0]) {
            translate([len/2, side * w/2, -h/2])
            color("darkgray") {
                cube([len, w, h], center=true);
            }
        }
    }
}

module nose_gear_doors_closed(len, w, h) {
    // Doors closed flush with fuselage
    for (side = [-1, 1]) {
        translate([len/2, side * w/2, -h/2])
        color("darkgray") {
            cube([len, w, h], center=true);
        }
    }
}

module main_gear_door_mechanism() {
    for (side = [-1, 1]) {
        let(y_pos = side * (fuse_width_max/2 + 5)) {
            main_gear_doors(side, y_pos);
        }
    }
}

module main_gear_doors(side, y_pos) {
    // Main gear doors - clamshell or single
    door_len = main_gear_strut_length + 8 * global_scale;
    door_w = 12 * global_scale;
    door_h = 14 * global_scale;
    
    gear_x = -fuse_length/2 + fuse_length * main_gear_position;
    gear_z = -fuse_height_max/2;
    
    translate([gear_x, y_pos, gear_z]) {
        if (main_gear_door_type == "clamshell") {
            // Two doors (forward and aft)
            if (show_gear_down) {
                main_clamshell_open(side, door_len, door_w, door_h);
            } else {
                main_clamshell_closed(side, door_len, door_w, door_h);
            }
        } else {
            // Single door
            if (show_gear_down) {
                main_single_door_open(side, door_len, door_w, door_h);
            } else {
                main_single_door_closed(side, door_len, door_w, door_h);
            }
        }
    }
}

module main_clamshell_open(side, len, w, h) {
    // Forward door
    rotate([0, side * -80, 0]) {
        translate([len/4, side * w/2, -h/2])
        color("darkgray") {
            cube([len/2, w, h], center=true);
        }
    }
    
    // Aft door
    rotate([0, side * 80, 0]) {
        translate([-len/4, side * w/2, -h/2])
        color("darkgray") {
            cube([len/2, w, h], center=true);
        }
    }
}

module main_clamshell_closed(side, len, w, h) {
    // Forward door closed
    translate([len/4, side * w/2, -h/2])
    color("darkgray") {
        cube([len/2, w, h], center=true);
    }
    
    // Aft door closed
    translate([-len/4, side * w/2, -h/2])
    color("darkgray") {
        cube([len/2, w, h], center=true);
    }
}

module main_single_door_open(side, len, w, h) {
    rotate([0, side * -90, 0]) {
        translate([len/2, side * w/2, -h/2])
        color("darkgray") {
            cube([len, w, h], center=true);
        }
    }
}

module main_single_door_closed(side, len, w, h) {
    translate([len/2, side * w/2, -h/2])
    color("darkgray") {
        cube([len, w, h], center=true);
    }
}

module main_door_linkage(side) {
    // Door actuation linkage
    color("darkgray") {
        // Linkage rod
        translate([0, side * 8 * global_scale, -main_gear_strut_length/2])
        rotate([0, 90, 0])
        cylinder(h = 10 * global_scale, r = 1 * global_scale, center=true);
        
        // Bellcrank
        translate([-5 * global_scale, side * 8 * global_scale, -main_gear_strut_length/2])
        cube([4 * global_scale, 2 * global_scale, 8 * global_scale], center=true);
    }
}

// ============================================================
// FIXED GEAR (Simple)
// ============================================================
module fixed_gear() {
    // Simple fixed gear for display/STL export
    gear_x = -fuse_length/2 + fuse_length * nose_gear_position;
    gear_z = -fuse_height_max/2;
    
    // Nose gear
    translate([gear_x, 0, gear_z]) {
        color("darkgray") {
            cylinder(h = nose_gear_strut_length, r = 2 * global_scale, center=true);
            translate([0, 0, -nose_gear_strut_length])
            wheel();
        }
    }
    
    // Main gear
    for (side = [-1, 1]) {
        let(y_pos = side * (fuse_width_max/2 + 5)) {
            translate([-fuse_length/2 + fuse_length * main_gear_position, y_pos, gear_z]) {
                color("darkgray") {
                    cylinder(h = main_gear_strut_length, r = 2.5 * global_scale, center=true);
                    translate([0, 0, -main_gear_strut_length])
                    wheel();
                }
            }
        }
    }
}

// For standalone preview
landing_gear();
