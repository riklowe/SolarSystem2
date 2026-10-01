//
//  SolarSystemDisplayCoordinates.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//

import Foundation
import SceneKit
import simd

enum SolarSystemDisplayCoordinates {

    private struct DistanceReference {
        let astronomicalUnits: Double
        let compactRadius: Double
    }

    private static let references: [DistanceReference] = [
        DistanceReference(astronomicalUnits: 0.387098, compactRadius: 0.60),
        DistanceReference(astronomicalUnits: 0.723332, compactRadius: 0.90),
        DistanceReference(astronomicalUnits: 1.000000, compactRadius: 1.20),
        DistanceReference(astronomicalUnits: 1.523679, compactRadius: 1.60),
        DistanceReference(astronomicalUnits: 5.204400, compactRadius: 2.70),
        DistanceReference(astronomicalUnits: 9.582600, compactRadius: 3.60),
        DistanceReference(astronomicalUnits: 19.218400, compactRadius: 4.60),
        DistanceReference(astronomicalUnits: 30.110400, compactRadius: 5.60),
        DistanceReference(astronomicalUnits: 39.482000, compactRadius: 6.60)
    ]

    static func compactPosition(from positionAU: SIMD3<Double>) -> SCNVector3 {

        let distanceAU = simd_length(positionAU)

        guard distanceAU > 0.0 else {
            return SCNVector3Zero
        }

        let compactRadius = compactRadius(for: distanceAU)
        let direction = positionAU / distanceAU

        return SCNVector3(
            Float(direction.x * compactRadius),
            Float(direction.z * compactRadius),
            Float(-direction.y * compactRadius)
        )
    }

    static func compactRadius(for distanceAU: Double) -> Double {

        guard let first = references.first, let last = references.last else {
            return distanceAU
        }

        if distanceAU <= first.astronomicalUnits {
            return interpolate(distanceAU, fromAU: 0.0, toAU: first.astronomicalUnits, fromRadius: 0.0, toRadius: first.compactRadius)
        }

        for index in 0..<(references.count - 1) {

            let lower = references[index]
            let upper = references[index + 1]

            if distanceAU <= upper.astronomicalUnits {
                return interpolate(distanceAU, fromAU: lower.astronomicalUnits, toAU: upper.astronomicalUnits, fromRadius: lower.compactRadius, toRadius: upper.compactRadius)
            }
        }

        let previous = references[references.count - 2]

        return interpolate(distanceAU, fromAU: previous.astronomicalUnits, toAU: last.astronomicalUnits, fromRadius: previous.compactRadius, toRadius: last.compactRadius)
    }

    private static func interpolate(_ value: Double, fromAU: Double, toAU: Double, fromRadius: Double, toRadius: Double) -> Double {

        guard toAU != fromAU else {
            return fromRadius
        }

        let fraction = (value - fromAU) / (toAU - fromAU)

        return fromRadius + fraction * (toRadius - fromRadius)
    }

#if DEBUG
    static func debugCompactEncounter(asteroid: NearEarthAsteroid) {

        let date = asteroid.encounterDate

        guard let asteroidPositionAU = NearEarthAsteroidAstronomy.heliocentricPositionAU(for: asteroid, date: date),
              let earthPositionAU = NearEarthAsteroidAstronomy.earthHeliocentricPositionAU(for: asteroid, date: date) else {
            print("Unable to calculate Compact encounter coordinates for \(asteroid.name)")
            return
        }

        let asteroidScenePosition = compactPosition(from: asteroidPositionAU)
        let earthScenePosition = compactPosition(from: earthPositionAU)

        let dx = Double(asteroidScenePosition.x - earthScenePosition.x)
        let dy = Double(asteroidScenePosition.y - earthScenePosition.y)
        let dz = Double(asteroidScenePosition.z - earthScenePosition.z)
        let displayedSeparation = sqrt(dx * dx + dy * dy + dz * dz)

        let physicalSeparationAU = simd_length(asteroidPositionAU - earthPositionAU)
        let physicalSeparationKM = physicalSeparationAU * 149_597_870.7

        let asteroidHeliocentricAU = simd_length(asteroidPositionAU)
        let earthHeliocentricAU = simd_length(earthPositionAU)

        print("")
        print("================ COMPACT NEA ENCOUNTER =================")
        print("Object: \(asteroid.designation)")
        print("Encounter: \(date)")
        print(String(format: "Asteroid heliocentric distance: %.9f AU", asteroidHeliocentricAU))
        print(String(format: "Earth heliocentric distance: %.9f AU", earthHeliocentricAU))
        print(String(format: "Physical Earth separation: %.3f km", physicalSeparationKM))
        print("")
        print(String(format: "Earth compact position:    %.6f  %.6f  %.6f", earthScenePosition.x, earthScenePosition.y, earthScenePosition.z))
        print(String(format: "Asteroid compact position: %.6f  %.6f  %.6f", asteroidScenePosition.x, asteroidScenePosition.y, asteroidScenePosition.z))
        print(String(format: "Compact separation: %.9f scene units", displayedSeparation))
        print("========================================================")
        print("")
    }
#endif
    
}
