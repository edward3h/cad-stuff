module turret() {
linear_extrude(16,scale=0.7)
//scale([0.91,0.91,0])
translate([-5,0,0])
polygon([[-25,10],[-17,16],[10,20],[20,0],[10,-20],[-17,-16],[-25,-10]]);
}

module hatch() {
translate([-3.7,0,13.1])
linear_extrude(3)
circle(d=20);
}

difference() {
turret();
    hatch();
}