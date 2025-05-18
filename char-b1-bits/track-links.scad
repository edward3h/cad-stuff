include <BOSL2/std.scad>

width = 15;
length = width / 2;
thick = 0.7;

rail_gap = 7.6;
rail_width = 1;
rail_height = 2;
$fn = 16;
delta=0.1;
tolerance=0.11;

joiner_radius = 1.2;
link_gap = 0.2;

module track_link(first=true,last=true) {
    diff() {
        prismoid(size1=[width,length/2],xang=30,yang=45,size2=[undef,undef],h=1.4,rounding1=length/4.4,rounding2=0.3,anchor=BOTTOM)
        position(BOTTOM)
        cuboid(size = [width, length, thick], rounding = length / 2.2, 
        edges = [FRONT+RIGHT, FRONT+LEFT, BACK+RIGHT, BACK+LEFT], anchor=TOP)
        position(BOTTOM) orient(BOTTOM)
        xcopies(rail_gap+rail_width) prismoid(size1 = [rail_width,length-1], size2 = [rail_width,undef], yang=45, h = rail_height,anchor=BOTTOM)
        position(BACK+BOTTOM)
        back(last ? 0.5 : (1+link_gap)/2) yrot(90) cyl(r=joiner_radius,h=rail_width);
        t = first ? tolerance : -tolerance;
        tag("remove") down(thick) fwd(length/2) xcopies(rail_gap+rail_width) yrot(90) cyl(r=joiner_radius+t,h=rail_width+t);
        if (!first) fwd((length+link_gap)/2) down(thick) cuboid([rail_gap,joiner_radius,thick]);
    }
}

module track_links(n=1) {
    ycopies(length+link_gap, n) track_link($idx == 0, $idx==(n-1));
}

track_links(10);
right(width*1.5) ycopies(l=width*3) track_links(3);
right(width*3) ycopies(l=width*4,n=4) track_links(2);
right(width*4.5) ycopies(l=width*4,n=6) track_links();