include <BOSL2/std.scad>

inner_r = 24.4/2+0.2;
outer_r = 29/2;
height = 6.2-4-0.7;
cham = min(outer_r - inner_r - 1, height/3);
$fn=60;
diff() {
    cyl(h = height, r = outer_r, chamfer2 = cham, chamfer1 = -cham, anchor = BOTTOM);
    tag("remove") down(1) cyl(h = height+2, r = inner_r, anchor = BOTTOM);

}