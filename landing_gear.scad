module wheel() {

    difference() {

        cylinder(h=4, r=5, center=true);

        cylinder(h=5, r=1.5, center=true);
    }
}


module landing_gear() {

    // Nose Gear
    translate([20,0,-15]) {

        cylinder(h=12, r=1.5);

        translate([0,0,-2])
        wheel();
    }

    // Left Main Gear
    translate([-35,15,-15]) {

        cylinder(h=12, r=1.5);

        translate([0,0,-2])
        wheel();
    }

    // Right Main Gear
    translate([-35,-15,-15]) {

        cylinder(h=12, r=1.5);

        translate([0,0,-2])
        wheel();
    }
}
