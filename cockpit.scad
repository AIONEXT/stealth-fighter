module cockpit() {

    // Pilot seat
    translate([0,0,2])
    cube([6,6,8], center=true);

    // Seat back
    translate([-2,0,8])
    rotate([0,20,0])
    cube([2,6,8], center=true);

    // Instrument panel
    translate([8,0,4])
    rotate([0,-45,0])
    cube([3,8,4], center=true);

}