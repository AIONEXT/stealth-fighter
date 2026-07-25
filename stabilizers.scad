module stabilizers() {

    translate([-55,18,12])
    rotate([70,15,0])
    linear_extrude(height=3)
    polygon([
        [0,0],
        [25,0],
        [6,25]
    ]);

    translate([-55,-18,12])
    rotate([110,15,0])
    linear_extrude(height=3)
    polygon([
        [0,0],
        [25,0],
        [6,25]
    ]);
}

stabilizers();