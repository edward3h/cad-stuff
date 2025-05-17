thick = 5;
w = 38.2;
h = 29.1;
tolerance = 0.1;
finger = 0.5;

linear_extrude(height = thick) 
difference() {
    square(size = [w + 3 * thick, h + 2 * thick], center = true);
    square(size = [w + (2 * tolerance) - (4 * finger), h + (2 * tolerance)], center = true);
    square(size = [w + (2 * tolerance) + (4 * finger), h / 2], center = true);
    translate(v = [w/2,0,0]) square(size = [finger, h], center = true);
    translate(v = [-w/2,0,0]) square(size = [finger, h], center = true);
    translate(v = [w/2+2*finger,0,0]) square(size = [finger, h], center = true);
    translate(v = [-(w/2+2*finger),0,0]) square(size = [finger, h], center = true);
}