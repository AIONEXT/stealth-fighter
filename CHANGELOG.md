# Changelog

## v1.0 (2026-09-23) - Major Release
Complete rewrite with parametric design, stealth features, and full detail.

### Airframe
- **Fuselage**: Area-ruled "coke bottle" shaping with 24 cross-sections, chine lines, edge alignment
- **Wings**: Lofted airfoil sections (NACA 4-digit), 48° LE sweep, 3° dihedral, -2° washout, blended root fairings
- **Control Surfaces**: Full-span ailerons (40% semi-span), inboard flaps (35% span), configurable deflection
- **Stabilizers**: V-tail (default, 50° dihedral) or conventional H-tail, all-moving surfaces (ruddervators/elevators/rudder)
- **Edge Alignment**: All edges aligned to common angles [45°, 35°, 25°, 15°, 5°]
- **Sawtooth Edges**: Configurable wavelength/amplitude for trailing edges and bay doors

### Propulsion
- **Intakes**: Three types selectable via `intake_type`:
  - DSI (F-35 style) - Compression bump, sharp cowl lip, boundary layer bleed doors, S-duct internal routing
  - Serpentine S-duct (F-22 style) - 2+ alternating bends hiding engine face, compression ramp
  - Conventional - Simple axisymmetric for reference
- **Exhausts**: Three nozzle types selectable via `exhaust_type`:
  - 2D Thrust Vectoring (F-22 style) - Rectangular, upper/lower petals ±15°, side petals for yaw, 12 serrations
  - Axisymmetric (F-35 style) - Round convergent-divergent, 4 petals, optional serrations
  - Faceted (F-117 style) - 7 flat panels at aligned angles, cooling ejector slots
- **IR Reduction**: Serrated trailing edges, cooling slots, afterburner ring option

### Weapons Systems
- **Internal Weapon Bays**: Two side-by-side bays (40×22×8mm), chine-aligned doors
- **Door Actuation**: 4 hydraulic actuators per door, 3 hinges, sawtooth RAM gap seals
- **Weapons**: 
  - AAM (AIM-120 style) - Lofted body, cruciform fins, guidance/warhead/motor sections
  - AGM (AGM-158 style) - Cylindrical body, folded wings for internal carriage, cruciform tail
  - Mixed loadout via `weapon_type` parameter
- **Launchers**: LAU-129 rails (4 lugs) or BRU-61 ejector racks (2 pistons)

### Landing Gear
- **Fully Retractable**: Nose (single wheel) + Main (dual-wheel bogie)
- **Oleo-Pneumatic Struts**: Two-stage upper/lower cylinders, realistic stroke (5-6mm)
- **Steering**: Nose gear ±60° via hydraulic actuator and steering arm
- **Brakes**: Main gear disc brakes with 4-piston calipers, anti-skid control box
- **Gear Doors**: Clamshell (2-door) or single-door types, actuated linkages
- **Torque Links**: Scissor links on all gear preventing strut rotation
- **Hydraulics**: Supply/return lines, retraction actuators
- **Retraction**: Forward/aft/lateral configurable

### Cockpit (Detailed Interior)
- **Ejection Seat** (ACES II / Martin-Baker):
  - Seat pan with cushion/structure, reclined back (18°) with headrest & lumbar
  - Catapult beams, drogue gun, stabilization rocket, parachute container, survival kit
  - 5-point harness with quick-release buckle, armrests, adjustment rails
- **Avionics**: 3× MFDs with bezels/buttons, standby instruments, 12 warning/caution lights
- **HUD**: Combiner glass (30°), projector unit, symbology (velocity/altitude tapes, horizon, FPM)
- **Side Consoles**: Throttle quadrant (dual), avionics panel (12 buttons+LEDs), switch panels (6 toggles)
- **Rudder Pedals**: Articulated with toe brakes, center support
- **Pilot Figure**: Articulated (helmet with gold visor/NVG mount/O2 connector, head, torso with G-suit/vest, arms on controls, legs on pedals), oxygen hose, seat harness connections
- **Canopy Rails**: Forward/aft guide rails with breakers

### Canopy
- **Frameless Stealth**: 12-section lofted profile, continuous curvature, chine-aligned edges
- **Gold Coating**: Visual indicator layer
- **Forward Frame**: Minimal windshield arch
- **Aft Fairing**: Blended into fuselage spine
- **Framed Option**: Traditional 4-frame canopy available

### Configuration System
- **config.scad**: 100+ parameters organized by category (Global, Fuselage, Wings, Stab, Canopy, Cockpit, Intakes, Exhausts, Bays, Gear, Stealth, Export)
- **Display Toggles**: Every component independently show/hide
- **State Overrides**: `show_open_doors`, `show_gear_down`, `show_pilot`, `show_weapons`
- **Scale/Resolution**: Global scale factor, adaptive mesh resolution

### Export & Printing
- **export.scad**: Helper modules for STL generation
- **Assembly Configurations**: Clean, Landing, Combat, Display
- **Individual Parts**: All components exportable separately
- **Print Splits**: Fuselage (3 sections), Wings (4 panels), Stabilizers (2 surfaces)
- **BOM Generator**: Print time, weight, material estimates
- **Print Settings**: Documented for Bambu/Prusa (0.16mm, 10% Gyroid, PLA+)

### Documentation
- **README.md**: Complete rewrite with parameter tables, printing guide, customization examples
- **Materials/**: PLA+, PETG, ABS, ASA, PA-CF, Colors reference sheets
- **Documentation/Costing.md**: Cost breakdown (₹430 total, ₹749 sale, ₹319 profit)

## v0.2
- Canopy
- Cockpit (basic)

## v0.1
- Fuselage
- Wings
- Stabilizers