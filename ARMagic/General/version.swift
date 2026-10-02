//
//  Version.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//
//  Project development history.
//  Add new entries at the TOP of the relevant version section.
//

/*

========================================================================
AR SOLAR SYSTEM — DEVELOPMENT HISTORY
========================================================================

Version 1.0 — Eclipses, Van Allen Belts and Display Modes
------------------------------------------------------------------------

• Added (35396) 1997 XF11 as the fourth fully modelled Near-Earth Asteroid.
• Added JPL Horizons encounter, Earth and long-term ephemeris datasets for the October 2028 1997 XF11 close approach.
• Validated the 26 October 2028 1997 XF11 closest approach at 06:43:34 UTC and approximately 929,227.6 km from Earth's centre, within approximately 0.4 km of the 929,228 km catalogue reference distance.
• Validated 1997 XF11 Earth-relative flyby rendering across the complete ±36-hour encounter window using 865 five-minute trajectory samples.
• Updated Near-Earth Asteroid encounter mode so Earth–Moon Scale displays only the currently selected encounter asteroid and its Earth-relative trajectory rather than all configured Near-Earth Asteroids.
• Updated Near-Earth Asteroid encounter selection to rebuild Earth–Moon Scale when selecting another asteroid while already in that display mode, ensuring each encounter displays its own trajectory.
• Validated isolated encounter rendering and trajectory switching for Apophis, 1999 AN10, 2001 WN5 and 1997 XF11.

• Added a persistent display-mode indicator beneath the simulation date/time showing the currently selected Solar System display scale.
• Added a generic Near-Earth Asteroid encounter selector populated from the shared NEA catalogue, allowing any configured asteroid encounter to be selected without asteroid-specific UI code.
• Added automatic Near-Earth Asteroid encounter navigation that switches to Earth–Moon Scale and starts the simulation 75 minutes before the selected close approach.
• Added production Near-Earth Asteroid flyby playback at approximately three simulated minutes per real second, replacing the earlier Apophis-specific DEBUG flyby test.
• Updated simulation pause/resume controls to preserve the specialised Near-Earth Asteroid flyby speed instead of reverting to normal simulation timing.
• Updated the NOW control to return to the current real-world date/time and rebuild the active display mode so Earth, Moon and Near-Earth Asteroid positions immediately match the current epoch.
• Validated encounter selection and flyby playback for Apophis, 1999 AN10 and 2001 WN5.

• Generalised Compact-mode Near-Earth Asteroid positioning using a shared radial mapping based on the existing planetary Compact display scale while preserving heliocentric direction.
• Validated Compact-mode encounter positioning for Apophis, 1999 AN10 and 2001 WN5.
• Corrected the JPL Horizons encounter-resource coverage for Apophis and 1999 AN10 to provide the complete ±36-hour Earth-relative flyby window.
• Validated complete Earth-relative flyby trajectories for Apophis, 1999 AN10 and 2001 WN5, each using 865 five-minute trajectory samples.

• Added (153814) 2001 WN5 as the third fully modelled Near-Earth Asteroid.
• Added JPL Horizons encounter, Earth and long-term ephemeris datasets for the June 2028 2001 WN5 close approach.
• Validated the 26 June 2028 2001 WN5 close approach at approximately 248,711 km from Earth's centre, within approximately 0.8 km of the 248,712 km reference distance.
• Validated 2001 WN5 Earth-relative flyby rendering across the complete ±36-hour encounter window using 865 five-minute trajectory samples.
• Validated 2001 WN5 rendering through the shared Compact-mode Near-Earth Asteroid coordinate mapping.

• Added (137108) 1999 AN10 as the second fully modelled Near-Earth Asteroid.
• Added JPL Horizons encounter, Earth and long-term ephemeris datasets for the August 2027 1999 AN10 close approach.
• Generalised Near-Earth Asteroid ephemeris resource handling so each asteroid can independently specify its encounter, long-term and matching Earth datasets.
• Generalised Earth-relative Near-Earth Asteroid encounter validation for reuse across the NEA catalogue.
• Validated the 7 August 2027 1999 AN10 close approach at approximately 389,855 km from Earth's centre, matching the reference distance to within approximately 0.01 km.
• Validated 1999 AN10 long-term trajectory rendering using 4,381 JPL Horizons ephemeris samples with an exact shared encounter vertex between the pre-encounter and post-encounter trajectories.
• Added Near-Earth Asteroid support as a dedicated solar-system subsystem, with independent astronomical positioning, rendering, trajectories and display controls.
• Added (99942) Apophis as the first fully modelled Near-Earth Asteroid.
• Added JPL Horizons ephemeris support for high-accuracy Near-Earth Asteroid positions and velocities.
• Added long-term Apophis ephemeris data covering 2028–2030, preserving the gravitational change to its heliocentric trajectory during the April 2029 Earth encounter.
• Added Hermite interpolation between JPL Horizons ephemeris samples for smooth date-dependent Near-Earth Asteroid positioning.
• Validated the Apophis 13 April 2029 close approach against matching JPL Earth and Apophis ephemerides, calculating an Earth-centre distance of approximately 38,007 km.
• Added pre-encounter and post-encounter Apophis trajectory rendering, joined through an exact interpolated encounter position.
• Added Earth-relative Apophis flyby rendering for Earth–Moon Scale mode.
• Added a DEBUG Apophis Flyby mode starting shortly before the 13 April 2029 close approach and running at approximately three simulated minutes per real second.
• Added a master Near-Earth Asteroids display setting for enabling or hiding the complete NEA subsystem.
• Added physically scaled Near-Earth Asteroid bodies in display modes where physical body scaling is appropriate.
• Added a non-physical locator crosshair for physically scaled Near-Earth Asteroids that would otherwise be too small to identify visually.
• Separated Near-Earth Asteroid scientific representation from navigation aids: trajectory and body position remain astronomical while the locator and label provide visual identification.
• Validated Apophis position, trajectory, locator and label behaviour across the current solar-system display modes.
• Corrected Earth–Moon orbit visualisation so the Moon orbit path is rebuilt for the selected simulation epoch and remains aligned with the calculated Moon position during the 2029 Apophis flyby.
• Added Realistic Spacing display mode using the displayed Sun radius as the physical scale reference for planetary orbital distances.
• Realistic Spacing uses 25% of the true Sun-to-orbit distance relationship, producing a scale of approximately 13.44 AR metres per astronomical unit.
• Extended Realistic Spacing to all major planets and Pluto using date-dependent heliocentric orbital positions rather than fixed mean orbital distances.
• Extended Realistic Spacing consistently to dwarf planets, dwarf-planet orbit paths and the Kuiper Belt.
• Extended adaptive moon-system scaling and enlarged moon visibility handling to Realistic Spacing.
• Added display-mode distance diagnostics showing calculated orbital semi-major axes and actual rendered AR distances whenever the solar-system display mode is changed.
• Added Realistic Spacing diagnostics showing instantaneous heliocentric distance in AU alongside actual rendered AR distance.
• Added Earth–Moon Scale diagnostics validating the rendered Earth/Moon radius ratio against the physical radius ratio.
• Added Earth–Moon Scale distance diagnostics comparing the instantaneous rendered Earth–Moon separation with the physical mean Earth–Moon distance.
• Validated all six display modes: Compact, True Body Scale, AU Orbit Spacing, Realistic Spacing, True Body + AU and Earth–Moon Scale.
• Validated Realistic Spacing planetary distances at approximately 13.44 AR metres per AU, including Neptune at approximately 402 metres and Pluto at approximately 479 metres for the current simulated epoch.
• Added a persistent Pluto display option allowing the Pluto–Charon system and Pluto's heliocentric orbit to be shown or hidden independently.
• Added a fifth display mode, True Body + AU, combining true relative body sizes with expanded astronomical-unit planetary orbit spacing.
• True Body + AU uses 1.0 scene unit per AU while retaining the existing True Body Scale Sun, planet, dwarf-planet and moon size ratios.
• Extended True Body + AU scaling to dwarf-planet positions, dwarf-planet orbit paths and the Kuiper Belt for consistent outer-Solar-System spacing.
• Refined Van Allen belt rendering across all display modes, with clearer orange inner and cyan outer radiation belts, improved point visibility and reduced visual clutter.
• Updated Kuiper Belt rendering to remain visible and appropriately positioned across Compact, True Body Scale and AU Orbit Spacing modes.
• Added four scale / display modes: Compact, True Body Scale, AU Orbit Spacing and Earth–Moon Scale.
• Added True Body Scale using real physical size ratios for the Sun, planets, dwarf planets and moons.
• Added AU Orbit Spacing using astronomical-unit planetary distance ratios while retaining enhanced body visibility.
• Added adaptive moon-system scaling in AU Orbit Spacing to prevent moon systems overlapping neighbouring planetary orbits.
• Added mode-aware planet, moon and dwarf-planet labels for readable presentation across different body scales.
• Added dedicated Earth–Moon Scale using the physical Earth/Moon radius ratio and physical Earth–Moon distance ratio.
• Retained the higher-accuracy EarthMoonAstronomy lunar ephemeris in Earth–Moon Scale, including varying lunar distance and orbital position.
• Centred Earth in Earth–Moon Scale while preserving date-dependent solar illumination direction.
• Preserved simulation time controls, planetary rotation and lunar motion while switching display modes.
• Added higher-accuracy Earth-Moon astronomy using Meeus-style lunar ephemeris terms.
• Updated Earth's Moon display position to use the improved EarthMoonAstronomy model.
• Updated the Moon's red orbit path to use the same EarthMoonAstronomy model as the displayed Moon position.
• Added physical solar-eclipse geometry calculations using Sun, Moon and Earth radii and distances.
• Added solar-eclipse umbra and penumbra calculations.
• Added geographic eclipse-shadow projection onto the Earth surface.
• Added visual eclipse-shadow rendering attached directly to the rotating Earth globe.
• Validated the 8 April 2024 eclipse path across Mexico, the United States, Canada and the Atlantic.
• Validated eclipse contact timing against published reference timing to close agreement.
• Added SceneKit Sun shadows using forward shadow rendering.
• Corrected Earth's texture longitude orientation for geographic eclipse alignment.
• Added Earth-centred Van Allen radiation belts using a simplified geomagnetic dipole model.
• Aligned the Van Allen belts to an approximately 11° tilted magnetic axis fixed relative to Earth.
• Replaced live Van Allen particle systems with static 3D point-cloud geometry for lower rendering overhead.
• Added a persistent Van Allen Belts display control.
• Replaced UISwitch-based display controls with lightweight custom toggle buttons to eliminate UIKit gesture stalls.
• Removed the equinox and solstice preset buttons from the display settings panel.
• Restored the normal fast-forward simulation control.
• Extended repeated time-control presses so normal forward/reverse steps increase by 1× and fast forward/reverse steps increase by 10×.
• Preserved existing display-setting persistence and ALL ON / ALL OFF behaviour.
• Stage 10 Eclipses / proper shadows COMPLETE.
• Stage 11 Van Allen radiation belts COMPLETE.
• Stage 12 Display controls COMPLETE.
• Stage 13 Scale / display modes COMPLETE.


Version 0.9 — Day, Night and Seasons
------------------------------------------------------------------------

• Retained Sun-centred illumination and dark, non-emissive planet night sides.
• Updated planetary pole orientations alongside date-dependent position and rotation.
• Added Earth equator, tropic and rotation-axis guides that inherit Earth's axial tilt.
• Added a persistent Earth Reference Lines switch, including ALL ON / ALL OFF.
• Added March/September equinox and June/December solstice presets for the simulation year.
• Derived approximate preset dates from the scene's orbital/pole model for 1800–2050.
• Paused and refreshed the solar system immediately after selecting a season preset.
• Preserved existing comet, zodiac, sky and display controls.
• Stage 9 Day / night / seasons COMPLETE.


Version 0.8 — Star Field and Milky Way
------------------------------------------------------------------------

• Added the 12 traditional zodiac constellation patterns and names using published star coordinates.
• Added a persistent Zodiac Constellations switch, including ALL ON / ALL OFF.
• Added seam-safe line drawing for Pisces and cached all sky-layer combinations.
• Zodiac patterns use a fixed equatorial reference; the surrounding sky remains illustrative.
• Added a repeatable procedural star field with varied star sizes, brightness and colour.
• Added a subtle illustrative Milky Way band with cloud structure and a dark dust lane.
• Added a distant panoramic background without scene geometry or translation parallax.
• Generated sky textures off the main thread and cached them for scene resets.
• Added independent persistent Stars and Milky Way switches, including ALL ON / ALL OFF.
• Preserved all existing display-setting keys and comet behaviour.
• Stage 8 Improved star field / Milky Way COMPLETE.


Version 0.7 — Comets and Display Settings
------------------------------------------------------------------------

• Fixed detached comet tails by anchoring tail rotation and activity scaling at the nucleus.
• Added Encke, 67P/Churyumov-Gerasimenko and Hale-Bopp alongside Halley.
• Added JPL SBDB orbital elements for the three additional comets, retaining each element set's epoch.
• Added date-dependent Keplerian comet motion, including highly eccentric and inclined orbits.
• Added comet nuclei, comae, anti-solar tails, yellow orbital paths and name labels.
• Added Sun-distance-dependent coma and tail activity.
• Added independent display controls for comet nuclei, tails / comae, orbit paths and labels.
• Added persistent UserDefaults display settings, including ALL ON / ALL OFF.
• Extracted the display-settings overlay into DisplaySettingsView.swift, preserving its appearance and controls.
• Kept GameViewController responsible for presenting settings and forwarding changes to SolarSystemBuilder.
• Preserved saved-setting keys and reapplied display preferences when rebuilding the solar system.
• Confirmed all four comets and attached tails working in the app.
• Stage 7 Comets COMPLETE.


Version 0.6 — Kuiper Belt and Dwarf Planets
------------------------------------------------------------------------

• Added a procedural Kuiper Belt with cold classical, hot classical, resonant and scattered populations.
• Added named Kuiper Belt dwarf planets Eris, Makemake and Haumea with independent orbital motion.
• Added independent display controls for dwarf planets, their labels and orbital paths.
• Stage 6 Kuiper Belt COMPLETE.


Version 0.5 — Pluto and Charon
------------------------------------------------------------------------

• Added Pluto using JPL/Standish long-range heliocentric orbital elements and correction term.
• Added Pluto's highly eccentric and inclined orbit to the AR solar-system display.
• Integrated Pluto into the generic planet data, rendering and update architecture.
• Added Pluto IAU pole orientation and absolute prime-meridian rotation.
• Added Charon with orbital motion around the Pluto-Charon system.
• Added Pluto-Charon barycentric motion using their relative gravitational parameters.
• Updated Charon's orbit visual to represent its barycentric orbit rather than a Pluto-centred orbit.
• Added synchronous Pluto-Charon rotation representing their mutual tidal lock.
• Validated Pluto-Charon tidal locking over multiple simulated orbital periods.
• Added an in-app display settings overlay with independent visibility controls for planets, moons, dwarf planets, orbit paths, labels, rings and the Kuiper Belt.
• Stage 5 Pluto + Charon COMPLETE.


Version 0.4 — Planetary Orbital Accuracy
------------------------------------------------------------------------

• Added JPL/Standish short-range planetary orbital elements for 1800-2050.
• Added JPL/Standish long-range planetary orbital elements for approximately 3000 BC-AD 3000.
• Added automatic selection between short-range and long-range planetary orbital models.
• Added long-range mean-anomaly correction terms for Jupiter, Saturn, Uranus and Neptune.
• Added Kepler equation solution for calculating planetary orbital positions.
• Added heliocentric ecliptic planetary position calculations.
• Added astronomical semi-major-axis scaling for position diagnostics.
• Added planet longitude, latitude and Sun-distance diagnostic calculations.
• Added short-range versus long-range orbital-model comparison diagnostic.
• Validated planetary orbital calculations at the current 2026 epoch.
• Validated long-range planetary orbital calculations at the year 2100.
• Validated the short-range/long-range model transition near the 2050 boundary.
• Confirmed maximum model-transition longitude difference is approximately 0.121° at Uranus.
• Stage 4 Planetary orbital accuracy / long-range model COMPLETE.


Version 0.3 — Planetary Rotation
------------------------------------------------------------------------

• Added date-dependent IAU prime-meridian rotation for all eight planets.
• Added IAU planetary north-pole right ascension and declination calculations.
• Added periodic pole corrections for planets requiring additional IAU terms.
• Added date-dependent Earth pole orientation instead of a fixed celestial pole.
• Added SceneKit planetary pole-alignment calculations.
• Added generic prime-meridian reference-offset calculation for planetary textures.
• Corrected SceneKit rotation direction using referenceOffset - primeMeridianAngle.
• Added support for naturally retrograde IAU rotation rates for Venus and Uranus.
• Added Greenwich reference-marker diagnostic for validating Earth's absolute rotation.
• Added generic planetary prime-meridian orientation diagnostics.
• Validated Earth's Greenwich orientation at 00:00 and 12:00 UTC.
• Validated absolute rotational orientation for Mercury through Neptune.
• Confirmed Saturn's residual orientation error is negligible SceneKit floating-point precision.
• Stage 3 Absolute planetary rotation COMPLETE.


Version 0.2 — Moons and Reference Planes
------------------------------------------------------------------------

• Added astronomical moon-position calculations.
• Added moon orbital reference-plane handling.
• Added moon orbit-path rendering.
• Added red moon orbit paths to distinguish them from planetary orbits.
• Improved moon positioning relative to parent planets.
• Added support for date-dependent moon positions.
• Corrected moon orbital orientation relative to planetary reference planes.
• Stage 2 Moon ephemerides / reference planes COMPLETE.


Version 0.1 — Solar System Scene
------------------------------------------------------------------------

• Added AR solar-system scene construction.
• Added the Sun and eight major planets.
• Added planetary texture mapping.
• Added scaled planetary sizes and display-orbit radii for AR visualisation.
• Added date-dependent planetary orbital positions.
• Added green planetary orbit-path rendering.
• Added planetary axial orientation support.
• Added Saturn and other planetary ring rendering.
• Corrected ring material rendering to prevent Saturn's rings appearing white.
• Added Sun omni-light illumination for planetary textures.
• Increased outer-planet display spacing for improved AR visibility.
• Added simulation clock with controllable astronomical date and time.
• Added simulation update loop for planetary and moon positions.
• Added SceneKit astronomy-to-AR coordinate conversion.
• Added structured debug logging using source filename and function name.


Supporting Astronomy / Solar-System Features
------------------------------------------------------------------------

• Added reusable Julian Date calculation.
• Added astronomical degree/radian conversion helpers.
• Added angle normalisation helpers.
• Added eccentric-anomaly solver.
• Added reusable orbital-element data structures.
• Added separate astronomy logic for planets, moons and asteroids.
• Added major-asteroid astronomy and scene-building support.
• Added background asteroid-belt support.
• Major and background asteroid rendering can currently be disabled independently.
• Added diagnostic functions that remain in source but can be enabled when required.


========================================================================
CURRENT DEVELOPMENT STATUS
========================================================================


Stage 1  — Major asteroids .................................... COMPLETE
Stage 2  — Moon ephemerides/reference planes .................. COMPLETE
Stage 3  — Absolute planetary rotation ........................ COMPLETE
Stage 4  — Planetary orbital accuracy/long-range model ........ COMPLETE
Stage 5  — Pluto + Charon ..................................... COMPLETE
Stage 6  — Kuiper Belt ........................................ COMPLETE
Stage 7  — Comets ............................................. COMPLETE
Stage 8  — Improved star field / Milky Way .................... COMPLETE
Stage 9  — Day / night / seasons .............................. COMPLETE
Stage 10 — Eclipses / proper shadows .......................... COMPLETE
Stage 11 — Van Allen radiation belts .......................... COMPLETE
Stage 12 — Display controls ................................... COMPLETE
Stage 13 — Scale / display modes .............................. COMPLETE


========================================================================

*/
