// Token set for budgies_gladius.svg, built on token_generator.scad.
//
// Render/export the whole sheet:
//   openscad --enable=textmetrics -o all_tokens.stl budgies_gladius_tokens.scad
//
// Render/export a single token by index (0-based, see TOKENS below):
//   openscad --enable=textmetrics -o token_0.stl -D TOKEN_INDEX=0 budgies_gladius_tokens.scad

include <token_generator.scad>

// [center_lines, rim_text, icon_name]
TOKENS = [
    [["-1", "To Hit"], "Suppressed", "quill"],
    [["+1", "To Hit"], "Multi-Spectrum Array", "quill"],
    [["Ignore", "Cover"], "Hammerstrike", "quill"],
    [["Reroll", "Hits"], "Oath of Moment", "quill"],
    [["Worsen", "AP by 1"], "Armour of Contempt", "quill"],
    [["Squad", "Doctrine"], "Adaptive Strategy", "quill"],
    [[], "Battle-Shock", "skull"],
];

// Set via -D TOKEN_INDEX=N on the command line to isolate a single token
// for export; leave undef to render the full grid.
TOKEN_INDEX = undef;

module token_from_def(def) {
    center_lines = def[0];
    rim_text = def[1];
    icon_name = def[2];
    if (icon_name == "skull")
        token(center_lines = center_lines, rim_text = rim_text,
              icon_name = icon_name, icon_height = 19, icon_y_frac = 0.05);
    else
        token(center_lines = center_lines, rim_text = rim_text, icon_name = icon_name);
}

if (TOKEN_INDEX != undef) {
    token_from_def(TOKENS[TOKEN_INDEX]);
} else {
    cols = 4;
    spacing = 40;
    for (i = [0:len(TOKENS)-1])
        translate([(i % cols) * spacing, -floor(i / cols) * spacing, 0])
            token_from_def(TOKENS[i]);
}
