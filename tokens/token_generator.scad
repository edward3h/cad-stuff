// Parametric generator for embossed game tokens (flat disc, chamfered
// edge, raised center text / curved rim text / optional icon).
//
// Requires OpenSCAD with textmetrics() enabled (experimental feature in
// 2021.01+, stable-ish in later dev snapshots):
//   openscad --enable=textmetrics ...

// Known icon SVGs and the native width/height of their viewBox, so the
// caller can request an icon by name and a target width in mm without
// having to know the source SVG's internal units.
function icon_lookup(name) =
    name == "quill" ? ["icons/quill.svg", [1040, 840]] :
    name == "skull" ? ["icons/skull.svg", [270, 366]] :
    undef;

// Sum of a numeric vector.
function vsum(v) = v == [] ? 0 : v[0] + vsum([for (i = [1:len(v)-1]) v[i]]);

// Advance width of each character in txt, in mm, for the given font/size.
function char_widths(txt, size, font) =
    [for (c = txt) textmetrics(c, size = size, font = font).advance[0]];

// Cumulative arc-length offset (from the start of the string) at which
// each character begins.
function char_starts(widths) =
    [for (i = [0:len(widths)-1]) vsum([for (j = [0:i-1]) widths[j]])];

// Places txt as raised(2D, to be extruded by the caller) glyphs along an
// arc of the given radius, centered on start_angle (degrees, standard
// OpenSCAD convention: 0 = +X axis, 90 = +Y axis), reading clockwise
// when viewed from above (matches a coin rim reading left-to-right along
// the top of the disc).
module curved_text(txt, radius, size = 5, font = "Bitter:style=Medium") {
    widths = char_widths(txt, size, font);
    starts = char_starts(widths);
    total = vsum(widths);
    for (i = [0:len(txt)-1]) {
        s_center = starts[i] + widths[i] / 2 - total / 2;
        theta = -(s_center / radius) * 180 / PI;
        a = 90 + theta;
        translate([radius * cos(a), radius * sin(a), 0])
            rotate([0, 0, a - 90])
                text(txt[i], size = size, font = font, halign = "center", valign = "baseline");
    }
}

// Wrapping this conditional in its own module (rather than a bare `if`
// as a direct child of a multi-child union) works around an OpenSCAD
// CSG-normalization bug where an `if` block's geometry can silently
// vanish when immediately followed by another multi-child module call
// (observed with 2026.02.25; the icon geometry disappeared only when a
// curved_text() call came right after a bare `if (icon != undef) {...}`
// sibling).
module icon_shape(name, width, y_offset) {
    icon = icon_lookup(name);
    if (icon != undef) {
        file = icon[0];
        native = icon[1];
        s = width / native[0];
        translate([0, y_offset, 0])
            scale([s, s])
                translate([-native[0] / 2, -native[1] / 2, 0])
                    import(file);
    }
}

module chamfered_disc(diameter, thickness, chamfer) {
    r = diameter / 2;
    union() {
        cylinder(h = chamfer, r1 = r - chamfer, r2 = r);
        translate([0, 0, chamfer]) cylinder(h = thickness - 2 * chamfer, r = r);
        translate([0, 0, thickness - chamfer]) cylinder(h = chamfer, r1 = r, r2 = r - chamfer);
    }
}

// icon_name: "quill", "skull", or undef for no icon.
//
// The icon sits at icon_emboss_height (lower relief) and text/rim text
// sit at the taller emboss_height, so where they overlap the text still
// physically stands proud of the icon underneath it and reads clearly
// on a single-colour print, similar to how the source SVG layers bold
// text over a background icon.
module token(
    diameter = 34.5,
    thickness = 3,
    chamfer = 0.6,
    emboss_height = 0.6,
    icon_emboss_height = 0.25,
    center_lines = ["-1", "To Hit"],
    center_size = 5,
    center_y_frac = 0,
    rim_text = "Suppressed",
    rim_size = 3.2,
    rim_radius_frac = 0.70,
    icon_name = "quill",
    icon_width = 15,
    icon_y_frac = 0,
    font = "Bitter:style=Medium"
) {
    r = diameter / 2;

    chamfered_disc(diameter, thickness, chamfer);

    translate([0, 0, thickness]) {
        // Icon, at a lower relief so overlapping text still reads above it.
        linear_extrude(icon_emboss_height)
            icon_shape(icon_name, icon_width, r * icon_y_frac);

        linear_extrude(emboss_height) {
            // Center text: 1-2 lines, vertically stacked, centered on
            // r*center_y_frac.
            n = len(center_lines);
            line_h = center_size * 1.25;
            for (i = [0:n-1])
                translate([0, r * center_y_frac + (n - 1) / 2 * line_h - i * line_h, 0])
                    text(center_lines[i], size = center_size, font = font,
                         halign = "center", valign = "center");

            // Curved rim text.
            curved_text(rim_text, radius = r * rim_radius_frac, size = rim_size, font = font);
        }
    }
}
