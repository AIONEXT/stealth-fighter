module fuselage() {

    hull() {

        translate([-70,0,0])
        scale([2,1,1])
        sphere(10);

        translate([-20,0,0])
        scale([3,1.3,1])
        sphere(10);

        translate([45,0,0])
        scale([1.2,.6,.5])
        sphere(8);
    }
}

fuselage();