include <BOSL2/std.scad>
include <BOSL2/screws.scad>

ps_width= 95;
ps_height=42;
depth=20;
radius=5;
thick=5;
delta=0.1;

diff() {
    cuboid(size=[ps_width+2*thick,ps_height+thick,depth],rounding=radius+thick/2,edges=[BACK+RIGHT,BACK+LEFT]) {
        attach(LEFT, RIGHT, align=FRONT)
        cuboid(size=[15,thick+radius,depth]);
       tag("remove") attach(LEFT, RIGHT, align=FRONT, inset=radius)
        cuboid(size=[15+delta,thick+radius,depth+delta],rounding=radius,edges=[FRONT+RIGHT]);

        attach(RIGHT, LEFT, align=FRONT)
        cuboid(size=[15,thick+radius,depth]);
       tag("remove") attach(RIGHT, LEFT, align=FRONT, inset=radius)
        cuboid(size=[15+delta,thick+radius,depth+delta],rounding=radius,edges=[FRONT+LEFT]);
    attach(FRONT, FRONT, inside = true, shiftout = delta)
    tag("remove") cuboid(size=[ps_width,ps_height,depth*2],rounding=5,edges=[BACK+RIGHT,BACK+LEFT]);
    attach(FRONT, TOP, overlap=thick+delta+1)
    tag("remove") xcopies(ps_width+15+thick+radius) screw_hole("#8-32", head="flat", l=18,counterbore=1);
    }
}