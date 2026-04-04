include <BOSL2/std.scad>

$fn = 32;

module scissor_leg(
    height            = 25,
    long_arm_angle    = 18,
    short_arm_angle   = 14,
    long_arm_width    = 2.5,
    long_arm_thick    = 1.0,
    short_arm_dia     = 1.8,
    lean_angle        = 5,
    foot_bar_overhang = 1.5,
    hub_dia           = 8.0,
    hub_thick         = 1.5,
    bolt_head         = true,
    boss_h            = 0.8,
    boss_dia          = 2.5,
    pivot_boss_h      = 1.2,
    pivot_boss_dia    = 3.0,
    bolt_head_h       = 0.6,
    bolt_head_dia     = 2.5,
    foot_bar_depth    = 3.0,
    foot_bar_thick    = 1.2,
    gusset_thick      = 0.6,
    fn_curve          = 32,
    fn_hex            = 6
) {
    // --- Derived values ---
    long_arm_len  = height / cos(long_arm_angle);
    short_arm_len = height / cos(short_arm_angle);

    long_arm_foot_x   =  long_arm_len  * sin(long_arm_angle);
    short_arm_foot_x  = -short_arm_len * sin(short_arm_angle);
    foot_bar_span     = long_arm_foot_x - short_arm_foot_x;
    foot_bar_len      = foot_bar_span + 2 * foot_bar_overhang;
    foot_bar_cx       = (long_arm_foot_x + short_arm_foot_x) / 2;

    // pivot_frac: aesthetic position along long arm (not a true geometric intersection;
    // both arms diverge from the hub so do not cross). Edit this constant directly
    // to reposition the boss after first visual check.
    pivot_frac = 0.55;
    pivot_x = pivot_frac * long_arm_len * sin(long_arm_angle);
    pivot_z = height - pivot_frac * long_arm_len * cos(long_arm_angle);

    // Uncomment to verify derived values during development:
    // echo("long_arm_len",  long_arm_len);   // ~26.3
    // echo("short_arm_len", short_arm_len);  // ~25.7
    // echo("foot_bar_span", foot_bar_span);  // ~14.3
    // echo("foot_bar_len",  foot_bar_len);   // ~17.3
    // echo("foot_bar_cx",   foot_bar_cx);    // ~0.95
    // echo("pivot_x",       pivot_x);        // ~4.5
    // echo("pivot_z",       pivot_z);        // ~11.2

    rotate([0, lean_angle, 0])
    union() {
        // Hub disc — bottom face at z=height, top face at z=height+hub_thick
        translate([0, 0, height])
        cyl(h=hub_thick, d=hub_dia, $fn=fn_curve, anchor=BOTTOM);

        // Long arm — flat bar, leans in +X direction
        // rotate([0, -angle, 0]) around Y axis leans the arm toward +X
        translate([0, 0, height])
        rotate([0, -long_arm_angle, 0])
        cuboid([long_arm_width, long_arm_thick, long_arm_len],
               rounding=0.3, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK],
               anchor=TOP);

        // Short arm — solid round rod, leans in -X direction
        translate([0, 0, height])
        rotate([0, short_arm_angle, 0])
        cyl(h=short_arm_len, d=short_arm_dia, $fn=fn_curve, anchor=TOP);

        // Long arm bottom pivot boss — anchor=BOTTOM so boss sits proud above ground (z=0 to z=boss_h)
        translate([long_arm_foot_x, 0, 0])
        cyl(h=boss_h, d=boss_dia, $fn=fn_curve, anchor=BOTTOM);

        // Short arm bottom pivot boss — anchor=BOTTOM so boss sits proud above ground (z=0 to z=boss_h)
        translate([short_arm_foot_x, 0, 0])
        cyl(h=boss_h, d=boss_dia, $fn=fn_curve, anchor=BOTTOM);

        // Main pivot boss — positioned at aesthetic crossing point of the two arms
        translate([pivot_x, 0, pivot_z]) {
            cyl(h=pivot_boss_h, d=pivot_boss_dia, $fn=fn_curve, anchor=BOTTOM);
            // Hex bolt head on top
            if (bolt_head)
                translate([0, 0, pivot_boss_h])
                cyl(h=bolt_head_h, d=bolt_head_dia, $fn=fn_hex, anchor=BOTTOM);
        }

        // Gusset plate — thin triangular fin at the pivot point, facing XZ plane
        // polygon Y-axis becomes Z after rotate([90,0,0]):
        //   base at pivot_z-2mm, tip at pivot_z+2mm
        // gusset_thick is marginal at 0.6mm (3 perimeters at 0.2mm nozzle); increase to 0.8 if needed
        translate([pivot_x, 0, pivot_z])
        rotate([90, 0, 0])
        linear_extrude(height=gusset_thick, center=true)
        polygon([[-2.5, -2], [2.5, -2], [0, 2]]);  // half-width 2.5mm, base -2mm, tip +2mm relative to pivot

        // Foot bar — spans between the two bottom pivots with overhang each side
        translate([foot_bar_cx, 0, 0])
        cuboid([foot_bar_len, foot_bar_depth, foot_bar_thick],
               rounding=0.4, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK],
               anchor=CENTER);

    }
}

scissor_leg();
