//
//  SolarSystemDisplayMode.swift
//  ARMagic
//
//  Stage 13 — Scale / Display Modes
//

import Foundation
import CoreGraphics

enum SolarSystemDisplayMode: String, CaseIterable {
    case compact
    case relativeSizes
    case astronomicalDistances
    case trueBodiesAstronomicalDistances
    case earthMoon

    var title: String {
        switch self {
        case .compact:
            return "Compact"

        case .relativeSizes:
            return "True Body Scale"

        case .astronomicalDistances:
            return "AU Orbit Spacing"

        case .trueBodiesAstronomicalDistances:
            return "True Body + AU"

        case .earthMoon:
            return "Earth–Moon Scale"
        }
    }

    var description: String {
        switch self {
        case .compact:
            return "AR-friendly layout with enlarged bodies and compressed orbital distances."

        case .relativeSizes:
            return "Sun, planets and moons shown at true relative body sizes while orbital spacing remains compact."

        case .astronomicalDistances:
            return "Planetary orbit spacing follows astronomical-unit ratios, with moon systems adjusted for visual clarity."

        case .trueBodiesAstronomicalDistances:
            return "True relative body sizes combined with astronomical-unit planetary orbit spacing, with moon systems adjusted for visual clarity."

        case .earthMoon:
            return "Earth and Moon shown with a more realistic relative size and distance relationship."
        }
    }
}

struct SolarSystemDisplayScale {
    let planetRadiusScale: CGFloat
    let moonRadiusScale: CGFloat
    let minimumPlanetRadius: CGFloat
    let minimumMoonRadius: CGFloat
    let astronomicalUnitsToSceneUnits: CGFloat
    let useAstronomicalPlanetDistances: Bool
    let usePhysicalMoonDistances: Bool
    let showOnlyEarthMoonSystem: Bool

    static func scale(for mode: SolarSystemDisplayMode) -> SolarSystemDisplayScale {
        switch mode {
        case .compact:
            return SolarSystemDisplayScale(
                planetRadiusScale: 0.10,
                moonRadiusScale: 0.15,
                minimumPlanetRadius: 0.0,
                minimumMoonRadius: 0.002,
                astronomicalUnitsToSceneUnits: 1.20,
                useAstronomicalPlanetDistances: false,
                usePhysicalMoonDistances: false,
                showOnlyEarthMoonSystem: false
            )

        case .relativeSizes:
            return SolarSystemDisplayScale(
                planetRadiusScale: 0.10,
                moonRadiusScale: 0.10,
                minimumPlanetRadius: 0.0,
                minimumMoonRadius: 0.0001,
                astronomicalUnitsToSceneUnits: 1.20,
                useAstronomicalPlanetDistances: false,
                usePhysicalMoonDistances: false,
                showOnlyEarthMoonSystem: false
            )

        case .astronomicalDistances:
            return SolarSystemDisplayScale(
                planetRadiusScale: 0.05,
                moonRadiusScale: 0.05,
                minimumPlanetRadius: 0.0,
                minimumMoonRadius: 0.0001,
                astronomicalUnitsToSceneUnits: 0.25,
                useAstronomicalPlanetDistances: true,
                usePhysicalMoonDistances: false,
                showOnlyEarthMoonSystem: false
            )

        case .trueBodiesAstronomicalDistances:
            return SolarSystemDisplayScale(
                planetRadiusScale: 0.10,
                moonRadiusScale: 0.10,
                minimumPlanetRadius: 0.0,
                minimumMoonRadius: 0.0001,
                astronomicalUnitsToSceneUnits: 1.00,
                useAstronomicalPlanetDistances: true,
                usePhysicalMoonDistances: false,
                showOnlyEarthMoonSystem: false
            )

        case .earthMoon:
            return SolarSystemDisplayScale(
                planetRadiusScale: 0.10,
                moonRadiusScale: 0.10,
                minimumPlanetRadius: 0.0,
                minimumMoonRadius: 0.0001,
                astronomicalUnitsToSceneUnits: 1.20,
                useAstronomicalPlanetDistances: false,
                usePhysicalMoonDistances: true,
                showOnlyEarthMoonSystem: true
            )
        }
    }
}
