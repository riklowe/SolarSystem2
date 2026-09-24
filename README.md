# AR Solar System

AR Solar System is an iOS augmented-reality astronomy application built with Swift, ARKit and SceneKit.

The project displays a dynamic 3D Solar System in AR, with date-dependent planetary positions, planetary rotation, moons, dwarf planets, comets, the Kuiper Belt, eclipses, the Van Allen radiation belts and multiple display-scale modes.

The aim of the project is to combine an accessible AR visualisation with progressively more accurate astronomical modelling.

---

## Features

### Augmented Reality Solar System

The Solar System is rendered directly into the user's environment using ARKit and SceneKit.

The scene includes:

- The Sun
- Mercury
- Venus
- Earth
- Mars
- Jupiter
- Saturn
- Uranus
- Neptune
- Pluto
- Major moons
- Dwarf planets
- Comets
- Kuiper Belt objects
- Planetary rings
- Planetary and lunar orbit paths
- Background stars and the Milky Way

The complete system can be viewed from different positions and angles by physically moving around the AR scene.

---

## Astronomical Planet Positions

Planetary positions are calculated for the selected simulation date rather than being placed at fixed points.

The application uses date-dependent orbital elements and solves the Kepler equation to determine heliocentric planetary positions.

Two orbital models are supported:

- Short-range planetary elements for approximately 1800–2050
- Long-range planetary elements covering approximately 3000 BC to AD 3000

The application automatically selects the appropriate model for the requested date.

Long-range correction terms are also applied where required for the outer planets.

---

## Planetary Rotation

Each planet rotates independently using astronomical rotation data rather than simple animation speeds.

The application includes:

- Date-dependent prime-meridian rotation
- Planetary north-pole orientation
- Axial tilt
- Retrograde rotation where appropriate
- Absolute rotational orientation
- Planet-specific rotation periods

This allows the visible face of a planet to correspond to the selected astronomical date and time.

Earth's texture alignment was also calibrated against the IAU prime-meridian reference used by the astronomy model.

---

## Planetary Orbits

Planetary orbit paths are generated dynamically from the same orbital elements used to position the planets.

The displayed orbits therefore include:

- Orbital eccentricity
- Inclination
- Longitude of ascending node
- Argument of perihelion

Planetary orbit paths are displayed in green.

---

## Moons

The application includes orbital modelling for the major moons of the Solar System.

Examples include:

### Earth
- Moon

### Mars
- Phobos
- Deimos

### Jupiter
- Amalthea
- Io
- Europa
- Ganymede
- Callisto

### Saturn
- Mimas
- Enceladus
- Tethys
- Dione
- Rhea
- Titan
- Hyperion
- Iapetus
- Phoebe

### Uranus
- Miranda
- Ariel
- Umbriel
- Titania
- Oberon

### Neptune
- Proteus
- Triton
- Nereid

### Pluto
- Charon

Moon positions are date dependent and use individual orbital parameters including:

- Semi-major axis
- Eccentricity
- Inclination
- Orbital period
- Ascending node
- Argument of periapsis
- Mean anomaly

Moon orbit paths are displayed in red.

---

## Higher-Accuracy Earth-Moon Model

Earth's Moon uses a separate higher-accuracy lunar astronomy model rather than the generic moon orbit calculation.

This includes Meeus-style lunar ephemeris terms for calculating:

- Lunar longitude
- Lunar latitude
- Earth-Moon distance
- Date-dependent geocentric Moon position

The visible Moon orbit is generated from the same astronomy model as the displayed Moon position so the orbit path and Moon remain consistent.

---

## Pluto and Charon

Pluto is fully integrated into the planetary system.

The Pluto-Charon system includes:

- Pluto's eccentric and inclined heliocentric orbit
- Date-dependent Pluto rotation
- Charon's orbital motion
- Pluto-Charon barycentric movement
- Synchronous tidal locking

Both Pluto and Charon orbit their common centre of mass rather than treating Pluto as completely stationary.

---

## Dwarf Planets

In addition to Pluto, the application includes:

- Ceres
- Eris
- Makemake
- Haumea

Each dwarf planet has:

- Date-dependent orbital positioning
- A visible orbit path
- A name label
- Independent display controls

---

## Kuiper Belt

A procedural Kuiper Belt surrounds the outer Solar System.

The belt contains multiple simulated populations:

- Cold classical objects
- Hot classical objects
- Resonant objects
- Scattered objects

Objects are generated using deterministic seeded random generation so the belt remains repeatable between runs.

The Kuiper Belt adapts its visual scale for the different Solar System display modes.

---

## Comets

The application currently includes:

- Halley's Comet
- Encke
- 67P/Churyumov-Gerasimenko
- Hale-Bopp

Comet motion is calculated from orbital elements using date-dependent Keplerian motion.

Each comet can include:

- Nucleus
- Coma
- Anti-solar tail
- Orbit path
- Name label

Comet activity changes with distance from the Sun.

The tail direction is always calculated relative to the Sun rather than simply following the comet's direction of travel.

---

## Solar and Lunar Eclipses

The application includes eclipse modelling using the calculated positions of the Sun, Earth and Moon.

The eclipse system includes:

- Solar eclipse geometry
- Umbra calculation
- Penumbra calculation
- Earth surface shadow projection
- Eclipse shadow rendering
- Date-dependent Moon position
- Earth rotation during the eclipse

The model was tested against the total solar eclipse of 8 April 2024.

The calculated eclipse path was visually validated across Mexico, the United States, Canada and the Atlantic.

---

## Day, Night and Seasons

Earth is illuminated from the actual simulated direction of the Sun.

The application models:

- Earth's axial tilt
- Planetary pole orientation
- Day and night
- Solar illumination direction
- Seasonal geometry
- Equinoxes
- Solstices

Optional Earth reference guides include:

- Equator
- Tropic of Cancer
- Tropic of Capricorn
- Rotation axis

---

## Van Allen Radiation Belts

Earth includes a visual representation of the Van Allen radiation belts.

Two radiation regions are displayed:

- Inner belt — orange
- Outer belt — cyan

The belts are rendered as static 3D point-cloud toroidal structures.

They are aligned approximately to Earth's geomagnetic axis, including an approximately 11° magnetic-axis tilt.

The visualisation scales automatically with the displayed Earth size and works across all display modes.

---

## Planetary Rings

Ring systems are included for the outer planets.

The application currently models rings for:

- Jupiter
- Saturn
- Uranus
- Neptune

Saturn uses a multi-band semi-transparent ring structure rather than a single flat ring texture.

Ring orientation follows the planet's rotational axis.

---

## Star Field and Milky Way

The application includes a generated deep-space background consisting of:

- Procedural stars
- Varied star brightness
- Varied star size
- Subtle colour variation
- Illustrative Milky Way band
- Dark Milky Way dust lane

The background remains visually distant and does not produce translation parallax when the user moves around the AR scene.

---

## Zodiac Constellations

The twelve traditional zodiac constellations can optionally be displayed.

The constellation layer includes named patterns based on published stellar coordinates.

The constellation display uses a fixed equatorial reference system.

---

# Display Modes

The app includes four different display modes because a truly scaled Solar System is extremely difficult to view in AR.

## Compact

Designed for practical AR use.

- Enlarged planets
- Enlarged moons
- Compressed orbital spacing
- All major Solar System objects visible within a manageable scene

This is the default visualisation mode.

---

## True Body Scale

Displays the Sun, planets, dwarf planets and moons using true relative body-size ratios.

The Sun is used as the size reference and all other bodies are scaled linearly from their real physical diameters.

Orbital distances remain compressed so the system can still be viewed in AR.

This mode demonstrates how small the terrestrial planets really are compared with the Sun and gas giants.

---

## AU Orbit Spacing

Planetary orbital spacing follows astronomical-unit ratios.

The application uses:

    1 AU = 0.25 SceneKit units

This preserves the relative orbital distances between the planets.

Moon systems are adaptively rescaled so that they remain visible without overlapping neighbouring planetary systems.

Moon body sizes are also visually enhanced so small moons remain visible at the larger planetary spacing.

---

## Earth-Moon Scale

A dedicated Earth-Moon educational mode.

Only Earth and the Moon are displayed.

The mode preserves:

- Real Earth-to-Moon radius ratio
- Real Earth-to-Moon distance ratio
- Date-dependent lunar distance variation
- Higher-accuracy lunar orbital position
- Earth's rotation
- Lunar orbital motion
- Solar illumination direction

Earth remains centred in the scene while the simulated Sun direction is updated independently.

This provides a much clearer demonstration of how far the Moon really is from Earth compared with the size of both bodies.

---

# Simulation Time

The Solar System can be run forward or backward through time.

Controls include:

- Pause
- Forward
- Reverse
- Fast forward
- Fast reverse
- Return to the current date and time

Repeated presses increase the simulation speed.

The selected date and time are continuously displayed at the top of the screen.

As simulation time changes, the application updates:

- Planet positions
- Planet rotation
- Moon positions
- Moon rotation
- Comet positions
- Dwarf planets
- Eclipse geometry
- Solar illumination

---

# Display Controls

A settings panel allows individual scene components to be enabled or disabled.

Controls include:

- Planets
- Moons
- Dwarf planets
- Planet orbits
- Moon orbits
- Dwarf planet orbits
- Planet labels
- Moon labels
- Dwarf planet labels
- Planetary rings
- Kuiper Belt
- Comets
- Comet tails
- Comet orbits
- Comet labels
- Stars
- Milky Way
- Zodiac constellations
- Earth reference lines
- Van Allen radiation belts

Settings are stored using `UserDefaults` and restored when the application is reopened.

---

# Dynamic Labels

Planet, moon and dwarf-planet labels automatically adapt to the selected display mode.

Different font scales and offsets are used for:

- Compact
- True Body Scale
- AU Orbit Spacing
- Earth-Moon Scale

This helps keep very small bodies readable while avoiding excessively large labels in close-up views.

---

# Technical Architecture

The project is primarily written in Swift and uses:

- Swift
- ARKit
- SceneKit
- UIKit
- SIMD mathematics

The codebase separates astronomy calculations from SceneKit rendering.

Major components include:

    SolarSystemBuilder
    SolarSystemData
    PlanetAstronomy
    MoonAstronomy
    EarthMoonAstronomy
    DwarfPlanetAstronomy
    CometAstronomy
    CometBuilder
    KuiperBelt
    StarfieldBuilder
    EclipseAstronomy
    EclipseShadowRenderer
    VanAllenBeltBuilder
    SceneFactory
    SimulationClock

This separation allows astronomical calculations to evolve independently from the AR rendering layer.

---

# Deterministic Procedural Generation

Procedural objects such as the Kuiper Belt use seeded random-number generators.

This means the same generated Solar System structure can be reproduced between runs rather than changing randomly every time the application starts.

---

# Accuracy vs Visualisation

A major design goal of the project is balancing astronomical accuracy with practical AR visualisation.

A completely true-scale Solar System would be almost impossible to view conveniently in an AR environment because:

- Planets are extremely small compared with the Sun
- Distances between planets are enormous
- Moons would often be invisible
- Planetary systems would occupy very different scales

The different display modes therefore allow the user to choose between:

- Practical visualisation
- Relative body-size accuracy
- Relative orbital-distance accuracy
- Focused Earth-Moon physical scale

Where visual exaggeration is used, it is deliberately separated from the underlying astronomical position calculations.

---

# Development

The application has been developed incrementally, with major stages including:

1. Major asteroid support
2. Moon ephemerides and reference planes
3. Absolute planetary rotation
4. Long-range planetary orbital modelling
5. Pluto and Charon
6. Kuiper Belt
7. Comets
8. Star field and Milky Way
9. Day, night and seasons
10. Eclipse modelling
11. Van Allen radiation belts
12. Display controls
13. Scale and display modes

All thirteen planned development stages are now complete.

---

# Future Development

Possible future areas include:

- Additional moons
- More dwarf planets and trans-Neptunian objects
- Additional comets and asteroids
- Improved high-precision planetary ephemerides
- More detailed eclipse prediction information
- Planet information panels
- Interactive object selection
- Distance and scale measurements
- Educational overlays
- AR object tracking and guided tours
- Search and navigation between Solar System objects
- Additional deep-sky content

---

# Purpose

This project is intended as both an AR visualisation and an educational astronomy application.

It demonstrates the Solar System as a dynamic system rather than a static model, allowing users to explore how planetary positions, rotations, moons, seasons, eclipses and other astronomical phenomena change over time.
