# Stealth Fighter v1.0

A highly detailed, parametric stealth fighter aircraft designed for 3D printing using OpenSCAD. Features accurate stealth shaping, detailed cockpit, weapon bays, retractable landing gear, and multiple export configurations.

![Stealth Fighter](https://img.shields.io/badge/OpenSCAD-2021.01+-orange)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/Version-1.0-green)

## Features

### Airframe
- **Fuselage**: Area-ruled "coke bottle" shaping with chine lines, edge-aligned panels for stealth
- **Wings**: High-sweep planform (48° LE), tapered airfoil sections, washout twist, blended wing-root fairings
- **Control Surfaces**: Full-span ailerons and inboard flaps with configurable deflection
- **Stabilizers**: V-tail (default) or conventional H-tail with all-moving surfaces (ruddervators/elevators/rudder)
- **Edge Alignment**: All major edges aligned to common angles (45°, 35°, 25°, 15°, 5°)

### Propulsion
- **Intakes**: Three types available:
  - DSI (Diverterless Supersonic Inlet) - F-35 style with compression bump
  - Serpentine S-duct - F-22 style with multiple bends hiding engine face
  - Conventional - Simple axisymmetric for reference
- **Exhausts**: Three nozzle types:
  - 2D Thrust Vectoring - F-22 style rectangular with upper/lower petals
  - Axisymmetric - F-35 style round convergent-divergent
  - Faceted - F-117 style flat-panel for maximum stealth
- **IR Reduction**: Serrated trailing edges, cooling slots, optional afterburner rings

### Weapons Systems
- **Internal Weapon Bays**: Two side-by-side bays with chine-aligned doors
- **Door Actuation**: Hydraulic actuators with hinge mechanisms
- **Weapons**: 
  - AAM (AIM-120 AMRAAM style) with cruciform fins
  - AGM (AGM-158 JASSM style) with folded wings
  - Mixed loadout support
- **Launchers**: LAU-129 style rails or BRU-61 ejector racks

### Landing Gear
- **Fully Retractable**: Nose gear (single wheel) + Main gear (dual-wheel bogie)
- **Oleo-Pneumatic Struts**: Two-stage with realistic stroke
- **Steering**: Nose gear steering (±60°)
- **Brakes**: Disc brakes with calipers on main gear
- **Gear Doors**: Clamshell or single-door types with linkages
- **Torque Links**: Scissor links preventing strut rotation

### Cockpit (Detailed Interior)
- **Ejection Seat**: ACES II / Martin-Baker style with:
  - Catapult beams, drogue gun, parachute container
  - 5-point harness, survival kit, armrests, adjustment rails
- **Avionics**: 3× MFDs, standby instruments, warning lights panel
- **HUD**: Combiner glass with flight symbology (velocity/altitude tapes, horizon, FPM)
- **Side Consoles**: Throttle quadrant (left), avionics/weapon panel (right)
- **Rudder Pedals**: Adjustable with toe brakes
- **Pilot Figure**: Articulated with helmet (gold visor), oxygen hose, G-suit

### Canopy
- **Frameless Stealth Design**: Continuous curvature, gold-coated representation
- **Edge Alignment**: Chine-matched edges for RCS reduction
- **Optional Framed**: Traditional multi-frame canopy available

## Quick Start

### Prerequisites
- OpenSCAD 2021.01 or later
- Recommended: OpenSCAD nightly for better performance

### Rendering
```bash
# Open main assembly
openscad assembly.scad

# Or open in OpenSCAD GUI and press F5 (preview) / F6 (render)
```

### Configuration
Edit `config.scad` to customize:
- Global scale, resolution
- Display options (gear up/down, doors open/closed, pilot visible)
- All dimensional parameters
- Stealth features (edge alignment, sawtooth, RAM)

## Parameter Reference

### Global Settings
| Parameter | Default | Description |
|-----------|---------|-------------|
| `global_scale` | 1.0 | Overall model scale factor |
| `resolution` | 100 | Mesh resolution ($fn) |
| `show_fuselage` | true | Toggle fuselage |
| `show_wings` | true | Toggle wings |
| `show_stabilizers` | true | Toggle tail |
| `show_canopy` | true | Toggle canopy |
| `show_cockpit` | true | Toggle cockpit interior |
| `show_intakes` | true | Toggle intakes |
| `show_exhausts` | true | Toggle exhausts |
| `show_bay_doors` | true | Toggle weapon bays |
| `show_landing_gear` | true | Toggle landing gear |
| `show_open_doors` | false | Weapon bay doors open |
| `show_gear_down` | true | Landing gear deployed |
| `show_pilot` | false | Show pilot figure |
| `show_weapons` | true | Show internal weapons |

### Fuselage
| Parameter | Default | Description |
|-----------|---------|-------------|
| `fuse_length` | 180mm | Overall length |
| `fuse_width_max` | 32mm | Max width |
| `fuse_height_max` | 24mm | Max height |
| `area_rule_waist` | 0.85 | Area ruling ratio |
| `nose_chine_angle` | 35° | Forward chine angle |

### Wings
| Parameter | Default | Description |
|-----------|---------|-------------|
| `wing_span` | 140mm | Total wingspan |
| `wing_root_chord` | 65mm | Root chord |
| `wing_tip_chord` | 20mm | Tip chord |
| `wing_sweep_le` | 48° | Leading edge sweep |
| `wing_sweep_te` | 15° | Trailing edge sweep |
| `wing_dihedral` | 3° | Dihedral angle |
| `wing_twist` | -2° | Washout (negative) |
| `aileron_deflection` | 15° | Aileron deflection |
| `flap_deflection` | 25° | Flap deflection |

### Stabilizers
| Parameter | Default | Description |
|-----------|---------|-------------|
| `stab_type` | "vtail" | "vtail" or "conventional" |
| `stab_span` | 60mm | Span per surface |
| `stab_dihedral` | 50° | V-tail angle |
| `stab_all_moving` | true | All-moving surfaces |
| `stab_deflection` | 20° | Max deflection |

### Intakes
| Parameter | Default | Description |
|-----------|---------|-------------|
| `intake_type` | "dsi" | "dsi", "serpentine", "conventional" |
| `intake_width` | 18mm | Capture width |
| `intake_height` | 14mm | Capture height |
| `intake_length` | 50mm | Duct length |
| `dsi_bump_height` | 8mm | DSI bump height |
| `intake_serpentine_bends` | 2 | S-duct bend count |

### Exhausts
| Parameter | Default | Description |
|-----------|---------|-------------|
| `exhaust_type` | "2d_vectoring" | "2d_vectoring", "axisymmetric", "faceted" |
| `exhaust_spacing` | 16mm | Nozzle spacing |
| `exhaust_nozzle_width` | 14mm | 2D nozzle width |
| `exhaust_nozzle_height` | 6mm | 2D nozzle height |
| `exhaust_thrust_vector` | 15° | Vector angle |
| `exhaust_serrations` | 12 | Serrations count |
| `exhaust_afterburner` | false | Show AB rings |

### Weapon Bays
| Parameter | Default | Description |
|-----------|---------|-------------|
| `bay_length` | 40mm | Bay length |
| `bay_width` | 22mm | Bay width |
| `bay_depth` | 8mm | Bay depth |
| `bay_door_angle` | 85° | Open angle |
| `weapon_type` | "aam" | "aam", "agm", "mixed" |
| `weapon_count` | 4 | Total weapons |
| `weapon_rail_type` | "launcher" | "launcher" or "ejector" |

### Landing Gear
| Parameter | Default | Description |
|-----------|---------|-------------|
| `gear_type` | "retractable" | "fixed" or "retractable" |
| `nose_gear_strut_length` | 25mm | Nose strut length |
| `main_gear_strut_length` | 22mm | Main strut length |
| `main_gear_wheel_diameter` | 16mm | Main wheel diameter |
| `gear_retract_direction` | "forward" | "forward", "aft", "lateral" |

### Stealth Features
| Parameter | Default | Description |
|-----------|---------|-------------|
| `align_edges` | true | Align edges to common angles |
| `sawtooth_edges` | true | Sawtooth trailing edges |
| `ram_panels` | true | RAM panel representation |
| `ram_gap_treatment` | true | Sawtooth gap seals |

### Export Settings
| Parameter | Default | Description |
|-----------|---------|-------------|
| `export_stl` | false | Enable STL export |
| `export_assembly` | true | Export full assembly |
| `export_individual` | false | Export individual parts |
| `stl_quality` | "high" | "low", "medium", "high", "ultra" |
| `export_directory` | "exports/" | Output directory |

## Export Configurations

Uncomment in `assembly.scad` or use `export.scad`:

1. **Clean Config** - Gear up, doors closed (low drag)
2. **Landing Config** - Gear down, doors closed
3. **Combat Config** - Gear up, bay doors open
4. **Display Config** - Gear down, doors open, pilot visible

### Individual Parts Export
```openscad
// In export.scad, uncomment:
export_fuselage();
export_wings();
export_stabilizers();
export_canopy();
export_cockpit();
export_intakes();
export_exhausts();
export_bay_doors();
export_landing_gear();
export_weapons();
```

### Print-Oriented Splits
```openscad
export_fuselage_sections();  // 3 sections
export_wing_panels();        // 4 panels (L/R inboard/outboard)
export_stab_panels();        // V-tail or H+V surfaces
```

## 3D Printing Guidelines

### Recommended Settings (Bambu Lab / Prusa / Generic)
| Setting | Value |
|---------|-------|
| Layer Height | 0.16 mm |
| Infill | 10% Gyroid |
| Material | PLA+ (recommended) |
| Nozzle Temp | 220°C |
| Bed Temp | 55°C |
| Supports | Tree / Organic |
| Orientation | Fuselage down, wings flat |

### Material Options
See `Materials/` folder:
- **PLA+** - Easy, low warp, good for display (default)
- **PETG** - Higher strength, outdoor capable
- **ABS/ASA** - High temp, UV resistant (ASA)
- **PA-CF** - Carbon fiber nylon, very strong, lightweight

### Print Sequence (Multi-part)
1. Fuselage sections (3 parts) → glue/join
2. Wing panels (4 parts) → join at spars
3. Stabilizers (2 parts)
4. Canopy (clear filament recommended)
5. Cockpit interior
6. Intakes, exhausts, bay doors
7. Landing gear (nose + 2 main)
8. Weapons (4 missiles)

### Estimated Print Time
- **Total**: ~27 hours
- **Total Weight**: ~193g (PLA+)
- **Material Cost**: ~₹180 (@ ₹1200/kg)

## File Structure
```
stealth-fighter/
├── assembly.scad          # Main assembly
├── config.scad            # All parameters
├── export.scad            # STL export helpers
├── fuselage.scad          # Fuselage with chine lines
├── wings.scad             # Wings with control surfaces
├── stabilizers.scad       # V-tail or conventional
├── canopy.scad            # Frameless stealth canopy
├── cockpit.scad           # Detailed interior
├── intakes.scad           # DSI / Serpentine / Conventional
├── exhausts.scad          # 2D TV / Axisymmetric / Faceted
├── baydoors.scad          # Weapon bays with missiles
├── landing_gear.scad      # Retractable gear with doors
├── README.md              # This file
├── CHANGELOG.md           # Version history
├── Documentation/
│   └── Costing.md         # Cost breakdown
└── Materials/
    ├── PLA+.md
    ├── PETG.md
    ├── ABS.md
    ├── ASA.md
    ├── PA-CF.md
    └── Colors.md
```

## Customization Examples

### F-22 Style (Serpentine Intakes, 2D TV)
```openscad
intake_type = "serpentine";
exhaust_type = "2d_vectoring";
stab_type = "vtail";
```

### F-35 Style (DSI Intakes, Axisymmetric)
```openscad
intake_type = "dsi";
exhaust_type = "axisymmetric";
stab_type = "vtail";
```

### F-117 Style (Faceted, No TV)
```openscad
exhaust_type = "faceted";
stab_type = "conventional";
align_edges = true;
sawtooth_edges = true;
```

### Large Scale (200% for display)
```openscad
global_scale = 2.0;
resolution = 150;
```

## Cost Breakdown (PLA+)
| Item | Cost (₹) |
|------|----------|
| Material (150g @ ₹1200/kg) | 180 |
| Electricity | 50 |
| Packaging | 100 |
| Shipping | 100 |
| **Total** | **430** |
| Selling Price | 749 |
| **Profit** | **319** |

## Version History
See [CHANGELOG.md](CHANGELOG.md)

## License
MIT License - Free for personal and commercial use.

## Contributing
Pull requests welcome! Please:
1. Keep changes parametric (use config.scad)
2. Maintain stealth design principles
3. Test rendering at multiple resolutions
4. Update CHANGELOG.md

## Acknowledgments
- OpenSCAD community
- Real aircraft reference: F-22, F-35, F-117, Su-57, J-20
- Stealth design principles from open literature