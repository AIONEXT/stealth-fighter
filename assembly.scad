show_open_doors = true;
if(show_open_doors)
    bay_doors_open();
else
    bay_doors_closed();

show_landing_gear = true;
if(show_landing_gear)
    landing_gear();
    show_landing_gear = true;
    show_landing_gear = false;

include <fuselage.scad>
include <wings.scad>
include <stabilizers.scad>
include <canopy.scad>
include <cockpit.scad>
include <intakes.scad>
include <exhausts.scad>
include <baydoors.scad>
include <landing_gear.scad>

fuselage();
wings();
stabilizers();

canopy();
cockpit();

intakes();
exhausts();

bay_doors_closed();

landing_gear();