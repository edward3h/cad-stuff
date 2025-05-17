include <BOSL2/std.scad>

width = 15;
length = width / 2;
thick = 0.7;

rail_inner = 7.6;
rail_outer = rail_inner + (2*2);
rail_height = 2;
$fn = 16;
delta=0.1;

difference() {
cuboid(size = [rail_outer, length + rail_height, rail_height], rounding=rail_height/2,
edges=[TOP+FRONT,BOTTOM+FRONT,TOP+BACK,BOTTOM+BACK])
position(TOP)
cuboid(size = [width, length, thick], rounding = length / 2-delta, 
edges = [FRONT+RIGHT, FRONT+LEFT, BACK+RIGHT, BACK+LEFT], anchor=TOP)
position(TOP)
prismoid(size1=[width,length/2],xang=30,yang=45,size2=[undef,undef],h=1.4,rounding1=1.8,rounding2=0.3,anchor=BOTTOM);
down(thick) cuboid(size=[rail_inner,length+rail_height+delta,rail_height+delta]);
fwd(length/2) cuboid(size=[rail_inner+2+delta,rail_height,rail_height+delta],rounding=rail_height/2,edges=[BACK+TOP]);
xcopies(rail_outer-delta,n=2) back(length/2) cuboid(size=[rail_height,rail_height,rail_height+delta],rounding=rail_height/2,edges=[FRONT+TOP]);
}
