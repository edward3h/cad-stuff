# Scissor-Action Mechanical Leg Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a single-piece parametric OpenSCAD model of an asymmetric scissor-action mechanical leg for a Necromunda Cawdor vehicle, printable flat on a Bambu Lab A1 Mini with a 0.2mm nozzle.

**Architecture:** A single `.scad` file containing one module, `scissor_leg()`, with all dimensions as named parameters. All derived values (arm lengths, pivot positions, foot bar span) are computed inside the module from those parameters. The file follows the existing repository conventions: `include <BOSL2/std.scad>` at top, global `$fn`, module definition, then a direct call at the bottom.

**Tech Stack:** OpenSCAD, BOSL2 (`include <BOSL2/std.scad>`)

**Spec:** `mech-model/docs/superpowers/specs/2026-04-04-scissor-leg-design.md`

---

## Coordinate System

The model is built upright: **Z is up**, hub at the top, ground at the bottom.

| Reference point | Z value |
|---|---|
| Ground (foot bar centre plane) | `z = 0` |
| Hub bottom face | `z = height` (= 25mm) |
| Hub top face | `z = height + hub_thick` (= 26.5mm) |

- **X** is the lean direction (arms spread in X as they descend).
- **Y** is the depth direction (arm cross-section thickness).
- Long arm leans in **+X**: `rotate([0, -long_arm_angle, 0])` (negative Y-rotation leans toward +X).
- Short arm leans in **−X**: `rotate([0, +short_arm_angle, 0])` (positive Y-rotation leans toward −X).
- `lean_angle` is applied via `rotate([0, lean_angle, 0])` around the **Y-axis**, tilting the whole leg in the XZ (side-view) plane.

### Key derived positions (at default parameters)

| Point | X (mm) | Z (mm) |
|---|---|---|
| Hub centre | 0 | 25 |
| Long arm bottom pivot | +8.1 | 0 |
| Short arm bottom pivot | −6.2 | 0 |
| Foot bar centre | +0.95 | 0 |
| Main pivot boss | +4.5 | +11.2 |

Pivot boss position along the long arm at `pivot_frac = 0.55`:
```
pivot_x = pivot_frac * long_arm_len * sin(long_arm_angle);
pivot_z = height - pivot_frac * long_arm_len * cos(long_arm_angle);
```

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `mech-model/scissor-leg.scad` | Create | Complete model — module definition + render call |

No other files needed.

---

## Chunk 1: Scaffold and hub disc

### Task 1: Create the file with module signature and echo diagnostics

**Files:**
- Create: `mech-model/scissor-leg.scad`

- [ ] **Step 1: Create the file**

```openscad
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

    pivot_frac = 0.55;
    pivot_x = pivot_frac * long_arm_len * sin(long_arm_angle);
    pivot_z = height - pivot_frac * long_arm_len * cos(long_arm_angle);

    echo("long_arm_len",  long_arm_len);
    echo("short_arm_len", short_arm_len);
    echo("foot_bar_span", foot_bar_span);
    echo("foot_bar_len",  foot_bar_len);
    echo("foot_bar_cx",   foot_bar_cx);
    echo("pivot_x",       pivot_x);
    echo("pivot_z",       pivot_z);

    rotate([0, lean_angle, 0])
    union() {
        // components go here
    }
}

scissor_leg();
```

- [ ] **Step 2: Open in OpenSCAD and confirm it renders without errors**

  Press **F5** (preview) or **F6** (render). Expected: empty scene, no error in console. Check the console shows all `echo()` values. Verify against expected defaults:

  | Echo key | Expected value |
  |---|---|
  | `long_arm_len` | ≈ 26.3 |
  | `short_arm_len` | ≈ 25.7 |
  | `foot_bar_span` | ≈ 14.3 |
  | `foot_bar_len` | ≈ 17.3 |
  | `foot_bar_cx` | ≈ 0.95 |
  | `pivot_x` | ≈ 4.5 |
  | `pivot_z` | ≈ 11.2 |

---

### Task 2: Add hub disc

- [ ] **Step 1: Add the hub disc inside `union()`**

Replace `// components go here` with:

```openscad
// Hub disc — bottom face at z=height, top face at z=height+hub_thick
translate([0, 0, height])
cyl(h=hub_thick, d=hub_dia, $fn=fn_curve, anchor=BOTTOM);
```

- [ ] **Step 2: Preview in OpenSCAD (F5)**

  Expected: a flat disc floating at z=25. Confirm it is 8mm across and 1.5mm tall using the measure tool or by visual check.

---

### Task 3: Commit scaffold

- [ ] **Step 1: Commit**

```bash
# Verify working tree first
git status

# Create branch (or switch to it if it already exists)
git checkout -b scissor-leg 2>/dev/null || git checkout scissor-leg

git add mech-model/scissor-leg.scad mech-model/docs/superpowers/
git commit -m "feat: scaffold scissor-leg module with hub disc"
```

---

## Chunk 2: Arms and bottom pivot bosses

### Task 4: Add the long arm (flat bar)

- [ ] **Step 1: Add the long arm after the hub disc**

```openscad
// Long arm — flat bar, leans in +X direction
// rotate([0, -angle, 0]) around Y axis leans the arm toward +X
translate([0, 0, height])
rotate([0, -long_arm_angle, 0])
cuboid([long_arm_width, long_arm_thick, long_arm_len],
       rounding=0.3, edges="Z",
       anchor=TOP);
```

  `anchor=TOP` places the arm's top face at the hub centre, so the arm extends downward.

- [ ] **Step 2: Preview (F5)**

  Expected: a flat bar descending from the hub disc, leaning to the right (+X). Its bottom end should reach approximately z=0 (ground level). Use OpenSCAD's **View → Show Axes** to verify.

---

### Task 5: Add the short arm (solid rod)

- [ ] **Step 1: Add the short arm**

```openscad
// Short arm — solid round rod, leans in -X direction
translate([0, 0, height])
rotate([0, short_arm_angle, 0])
cyl(h=short_arm_len, d=short_arm_dia, $fn=fn_curve, anchor=TOP);
```

- [ ] **Step 2: Preview (F5)**

  Expected: a solid rod descending from the hub centre, leaning to the left (−X). Together with the long arm, the two should form a V/diamond shape. The arms will overlap slightly near the hub — this is correct for a static model.

---

### Task 6: Add bottom pivot bosses

Each arm has a small cylindrical boss at its bottom end, sitting at ground level (z=0).

- [ ] **Step 1: Add the long arm bottom pivot boss**

```openscad
// Long arm bottom pivot boss — anchor=BOTTOM so boss sits proud above ground (z=0 to z=0.8)
translate([long_arm_foot_x, 0, 0])
cyl(h=0.8, d=2.5, $fn=fn_curve, anchor=BOTTOM);
```

- [ ] **Step 2: Add the short arm bottom pivot boss**

```openscad
// Short arm bottom pivot boss
translate([short_arm_foot_x, 0, 0])
cyl(h=0.8, d=2.5, $fn=fn_curve, anchor=BOTTOM);
```

- [ ] **Step 3: Preview (F5)**

  Expected: two small boss cylinders sitting proud at ground level (z=0 to z=0.8mm), one under each arm.

---

### Task 7: Commit arms

- [ ] **Step 1: Commit**

```bash
git add mech-model/scissor-leg.scad
git commit -m "feat: add scissor arms and bottom pivot bosses"
```

---

## Chunk 3: Pivot boss, gusset, foot bar, and final check

### Task 8: Add main pivot boss and hex bolt head

The boss sits at `(pivot_x, 0, pivot_z)` — approximately 55% down the long arm, visually in the middle of the diamond.

- [ ] **Step 1: Add the pivot cylinder**

```openscad
// Main pivot boss
translate([pivot_x, 0, pivot_z]) {
    cyl(h=1.2, d=3.0, $fn=fn_curve, anchor=BOTTOM);
    // Hex bolt head on top
    if (bolt_head)
        translate([0, 0, 1.2])
        cyl(h=0.6, d=2.5, $fn=fn_hex, anchor=BOTTOM);
}
```

- [ ] **Step 2: Preview (F5)**

  Expected: a cylindrical boss with a hexagonal top sits roughly in the centre of the diamond. If it looks too high or low, adjust `pivot_frac` (currently 0.55) until it sits visually in the middle of the X crossing.

---

### Task 9: Add gusset plate

A thin triangular plate behind/around the pivot boss, giving it an industrial look.

- [ ] **Step 1: Add the gusset**

```openscad
// Gusset plate — thin triangle centred on pivot point
translate([pivot_x, 0, pivot_z])
rotate([90, 0, 0])  // rotate so plate faces outward in XZ plane
linear_extrude(height=0.6, center=true)
polygon([[-2.5, -2], [2.5, -2], [0, 2]]);
```

  This creates a triangle 5mm wide at the base, 4mm tall, 0.6mm thick. The polygon's local Y-axis (before rotation) becomes Z after `rotate([90,0,0])`, so the base sits at `pivot_z − 2mm` and the tip at `pivot_z + 2mm`. Adjust the polygon vertices after the first preview if the gusset looks too high or low relative to the boss.

- [ ] **Step 2: Preview (F5)**

  Expected: a thin triangular fin at the pivot point. Rotate the view to confirm it is visible from the side and doesn't protrude excessively.

---

### Task 10: Add foot bar

The foot bar is a wide flat bar spanning the two bottom pivot positions.

- [ ] **Step 1: Add the foot bar**

```openscad
// Foot bar — spans between the two bottom pivots, with overhang each side
// Centred horizontally on the midpoint of the two pivot positions
translate([foot_bar_cx, 0, 0])
cuboid([foot_bar_len, 3.0, 1.2],
       rounding=0.4, edges="Z",
       anchor=CENTER);
```

  The foot bar's Y-dimension (3.0mm) is its depth; its Z-dimension (1.2mm) is its thickness. It is centred at z=0, so its bottom face sits at z=−0.6mm.

- [ ] **Step 2: Preview (F5)**

  Expected: a wide flat bar at the bottom of the leg, connecting the two pivot bosses and extending slightly beyond them on each side. The leg should now look like a complete diamond/scissor shape.

---

### Task 11: Apply lean and verify bounding box

The `lean_angle` is already applied in the scaffold — `rotate([0, lean_angle, 0])` wraps the whole `union()`. This step verifies it looks correct.

- [ ] **Step 1: Preview with lean (F5)**

  The default `lean_angle = 5` should tilt the whole leg slightly in the +X direction, making it look characteristically off-plumb. Set `lean_angle = 0` momentarily to confirm the un-leaned version looks symmetric, then restore to 5.

- [ ] **Step 2: Verify bounding box via echo**

  Add these temporary echo lines inside the module (just before the closing `}` of `union()`) to verify the key Z extents:

  ```openscad
  echo("Expected hub top Z",    height + hub_thick);       // → 26.5
  echo("Expected foot bar bot Z", -1.2/2);                 // → -0.6
  echo("Expected total height",  height + hub_thick + 1.2/2); // → 27.1
  ```

  Check the console confirms those values. Remove the echo lines before the final commit. Note: with `lean_angle = 5` the actual bounding box extents will shift slightly — set `lean_angle = 0` temporarily to get the clean 27.1mm total.

- [ ] **Step 3: Full render (F6)**

  Expected: clean manifold solid, no warnings in console.

---

### Task 12: Add `.gitignore` and final commit

- [ ] **Step 1: Add `.superpowers/` to repo `.gitignore`**

  Run from the repo root (`cad-stuff/`):

```bash
grep -qxF '.superpowers/' .gitignore 2>/dev/null || echo '.superpowers/' >> .gitignore
```

- [ ] **Step 2: Export to `.3mf` for slicing**

  In OpenSCAD: **File → Export → Export as 3MF**. Save as `mech-model/scissor-leg.3mf`.

  Open in Bambu Studio. Rotate 90° so the leg lies flat on the build plate (long arm face down). Confirm:
  - No supports generated
  - No thin-wall warnings (particularly on the gusset plate — increase `0.6` to `0.8` in the polygon extrude if flagged)
  - Layer preview looks reasonable

- [ ] **Step 3: Commit**

```bash
git add mech-model/scissor-leg.scad mech-model/scissor-leg.3mf .gitignore
git commit -m "feat: complete scissor-leg model — ready for test print"
```

---

## Tuning Guide

After the first test print, these are the most likely adjustments:

| Issue | Parameter to change |
|---|---|
| Leg too tall / too short | `height` |
| Arms too wide / narrow spread | `long_arm_angle`, `short_arm_angle` |
| Pivot boss looks out of place | Edit `pivot_frac` in the module source (local variable, currently 0.55) |
| Foot bar too short / long | `foot_bar_overhang` |
| Gusset too large | Edit polygon vertices in Task 9 |
| Arms too thin / fragile | `long_arm_width`, `long_arm_thick`, `short_arm_dia` |
| Lean too much / little | `lean_angle` |
