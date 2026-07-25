module bay_doors_closed() {

    translate([-10,6,-2])
    cube([35,1,1], center=true);

    translate([-10,-6,-2])
    cube([35,1,1], center=true);

}


module bay_doors_open() {

    translate([-10,7,-2])
    rotate([0,20,0])
    cube([35,1,1], center=true);

    translate([-10,-7,-2])
    rotate([0,-20,0])
    cube([35,1,1], center=true);

}
