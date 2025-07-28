include <BOSL2/std.scad>

old_diameter = 25.2;
new_diameter = 28.5;
// new_diameter = 40;
rise = 3;
rim = 1.5;
rim_height = 2;
delta=0.1;
magnet_diameter = 4.8;
magnet_height = 2.3;

top_radius = old_diameter + rim * 4 > new_diameter ? new_diameter/2 : old_diameter / 2 + rim;
$fa=5;
diff() {
cylinder(r=new_diameter/2, h=rise)
attach(TOP,BOTTOM)
cylinder(h = rim_height, r = top_radius)
attach(TOP,BOTTOM,inside=true,shiftout=delta)
tag("remove") cylinder(h=rim_height, r=old_diameter/2)
attach(TOP, BOTTOM,overlap=magnet_height-rise-delta-delta)
tag("remove") #cylinder(h=magnet_height, r=magnet_diameter/2,$fn=16);
}