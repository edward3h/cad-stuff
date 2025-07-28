include <BOSL2/std.scad>

height = 0.8;
depth = 1;
length = 27;
inner_length = length - 2* depth;

difference() {
prismoid(size1 = length, size2 = inner_length, chamfer1 = depth, h = height, anchor=BOTTOM);
tag("remove") cuboid(size=inner_length-0.6);
}