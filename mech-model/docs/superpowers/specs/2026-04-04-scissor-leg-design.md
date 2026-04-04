# Scissor-Action Mechanical Leg — Design Spec

## Context

A mechanical leg to be kitbashed onto an existing Necromunda vehicle model for a Cawdor gang. The vehicle has a "cobbled together from mismatched parts" aesthetic. The leg replaces a wheel and will be physically attached using putty or scratch-building techniques; no designed attachment interface is needed. The design should look low-tech and improvised, deliberately different from any other legs already on the model.

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Mechanism | Asymmetric scissor (4-bar linkage) | Reads clearly as mechanical; canted/asymmetric = Cawdor salvage aesthetic |
| Pose | Mid-extension (~45° arms) | Classic diamond silhouette; most readable as a scissor at a glance |
| Long arm profile | Flat bar | Wide, thin stamped-steel look |
| Short arm profile | Solid round rod | Contrasting profile; hollow tube not viable at this scale |
| Pivot | Off-centre, with hex bolt boss + gusset | Off-centre = asymmetric; gusset adds industrial detail |
| Output | Single-piece static print | No assembly required |

## Geometry

In this scissor configuration both arms share the same top connection (hub disc) and the same bottom connection (foot bar). Each arm therefore spans the full hub-to-ground height. The crossing point of the two arms is purely visual — it is where they physically intersect, not an endpoint. The crossing position is fully determined by the two arm angles; it is not an independent parameter.

- **Hub-to-ground height:** 25mm, measured from the underside of the hub disc (bottom face) to the ground plane. The hub disc centre sits 0.75mm above this reference (half the 1.5mm disc thickness); this is informational only and is not used in the bounding-box formula.
- **Long arm angle:** +18° from vertical (leans forward). Required length to span 25mm: 25 ÷ cos(18°) ≈ **26.3mm**.
- **Short arm angle:** −14° from vertical (leans back). Required length to span 25mm: 25 ÷ cos(14°) ≈ **25.7mm**.
- **Horizontal spread at the foot bar:**
  - Long arm bottom end: 26.3 × sin(18°) ≈ 8.1mm forward of hub centre
  - Short arm bottom end: 25.7 × sin(14°) ≈ 6.2mm behind hub centre
  - Derived foot bar span between pivot centres: ~14.3mm
- **Arm crossing point (where pivot boss sits):** computed as the intersection of the two arm lines in the X–Y plane. At the default angles this falls approximately 55% down the long arm (from hub end), but this is a derived value, not a parameter.
- **`lean_angle`:** a rigid-body rotation applied to the entire assembled leg. The rotation axis passes through the hub centre parallel to the X-axis (i.e., the leg tips in the front-back/side-view plane). At the default value of 5° the foot contact point shifts slightly forward and the leg looks characteristically off-plumb. Set to 0 for a perfectly vertical leg.

These are starting-point values. Adjust `long_arm_angle` and `short_arm_angle` in the module to taste once the model is visible in OpenSCAD — arm lengths and the crossing point are derived automatically.

## Component Dimensions

| Component | Profile | Approx. dims |
|---|---|---|
| Long arm | Flat bar | 2.5mm wide × 1.0mm thick × 26.3mm long |
| Short arm | Solid round rod | 1.8mm diameter × 25.7mm long |
| Main pivot boss | Cylinder + hex bolt head | 3.0mm dia × 1.2mm tall; hex head 2.5mm across-flats × 0.6mm tall |
| Gusset plate | Thin triangle | ~4mm × 4mm, 0.6mm thick (marginal — 3 perimeters at 0.2mm nozzle; watch for under-extrusion) |
| Bottom pivot bosses (×2) | Short cylinder | 2.5mm dia × 0.8mm tall |
| Foot bar | Flat bar (wider) | 3.0mm wide × 1.2mm thick × ~14mm long |
| Hub mount disc | Flat disc | 8.0mm dia × 1.5mm thick |

## Structure

```
scissor_leg()
  ├── hub_disc            — flat disc at top; top face is the visual hub attachment area
  ├── long_arm            — flat bar cuboid, rotated +long_arm_angle° from vertical
  │     └── bottom_pivot  — small cylinder boss at the arm's bottom end
  ├── short_arm           — solid cylinder, rotated −short_arm_angle° from vertical
  │     └── bottom_pivot  — small cylinder boss at the arm's bottom end
  ├── main_pivot_boss     — cylinder + hex prism, positioned at the geometric intersection
  │                         of the two arms (0.55 × long_arm_length down the long arm,
  │                         measured from the hub end along the arm's own axis)
  ├── gusset_plate        — thin triangular prism centred on the main pivot intersection
  └── foot_bar            — flat bar spanning the two bottom pivot points
```

## Module Signature

```openscad
module scissor_leg(
  height            = 25,    // hub underside to ground, mm
  long_arm_angle    = 18,    // degrees from vertical, positive = forward lean
  short_arm_angle   = 14,    // degrees from vertical, positive = backward lean
  long_arm_width    = 2.5,   // flat bar width, mm
  long_arm_thick    = 1.0,   // flat bar thickness, mm
  short_arm_dia     = 1.8,   // solid rod diameter, mm
  lean_angle        = 5,     // rigid-body tilt of whole leg about hub centre, degrees
  foot_bar_overhang = 1.5,   // how far foot bar extends beyond each pivot boss centre, mm
  hub_dia           = 8.0,   // hub disc diameter, mm
  hub_thick         = 1.5,   // hub disc thickness, mm
  bolt_head         = true,  // add hex bolt head detail on main pivot
  fn_curve          = 32,    // $fn for circular cross-sections (cylinders, rod arm)
  fn_hex            = 6      // $fn for hex bolt head (must be 6)
) { ... }
```

Key derived values inside the module:
```openscad
long_arm_len  = height / cos(long_arm_angle);
short_arm_len = height / cos(short_arm_angle);
// Bottom pivot positions (relative to hub centre at origin, before lean_angle rotation):
long_arm_foot_x  =  long_arm_len  * sin(long_arm_angle);
short_arm_foot_x = -short_arm_len * sin(short_arm_angle);
foot_bar_span    = long_arm_foot_x - short_arm_foot_x;  // ~14.3mm at defaults
foot_bar_len     = foot_bar_span + 2 * foot_bar_overhang;
// Arm crossing point (pivot boss position):
// Solve intersection of the two arm lines; no free parameter needed.
```

**Ground plane reference:** The hub underside is placed at `y = height = 25`. The arm bottom-end pivot centres sit at `y = 0`. The foot bar is centred vertically on these pivot centres, so its bottom face is at `y = -foot_bar_thick/2 = -0.6mm`. The ground plane for visual purposes is at `y = 0` (pivot centre level); the foot bar protrudes 0.6mm below this. The bounding box therefore spans from `y = -0.6mm` to `y = height + hub_thick = 26.5mm`, a total height of **27.1mm**.

## Print Setup

- **Printer:** Bambu Lab A1 Mini, 0.2mm nozzle, PLA
- **Orientation:** Flat on build plate — the leg lies on its side, face of the flat bar arm facing down. No supports required.
- **Notes:**
  - Flat bar arm at 1.0mm thick = 5 layers at 0.2mm layer height. Functional but do not go thinner.
  - Round rod arm prints as a vertical circle when lying flat — structurally sound but the cross-section will show layer lines on the curved face. Acceptable for tabletop scale.
  - Gusset plate at 0.6mm = 3 perimeters. Flag for under-extrusion during first print; increase to 0.8mm if it fails.
  - `$fn` values are controlled via the `fn_curve` and `fn_hex` module parameters; no hard-coded `$fn` calls in the geometry.

## Verification

1. Render the model in OpenSCAD (`F6`).
2. Use `echo(...)` to confirm `long_arm_len` and `short_arm_len` match expected values for the chosen angles.
3. Measure the bounding box height in OpenSCAD — it should be `height + hub_thick + foot_bar_thick/2` = 25 + 1.5 + 0.6 = **27.1mm** (hub top face to foot bar bottom face).
4. Confirm the diamond silhouette reads clearly from the side view.
5. Check no feature is thinner than 0.4mm.
6. Export to `.3mf`, slice in Bambu Studio — confirm flat-on-plate orientation, no supports generated, no thin-wall warnings.
7. Print a test piece and offer it up to the vehicle's wheel position by eye. Adjust angles and proportions in the module parameters and re-print as needed.
