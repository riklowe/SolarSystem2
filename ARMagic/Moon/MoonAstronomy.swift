//
//  MoonAstronomy.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import simd

enum MoonAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - ORBITAL POSITION
    // ============================================================

    static func orbitalPosition(
        for moon: Moon,
        parentPlanetName: String,
        date: Date,
        sceneUnitsPerKilometre: Double? = nil
    ) -> SCNVector3 {

        // --------------------------------------------------------
        // Earth's Moon
        //
        // Use the higher-accuracy lunar theory required for phases,
        // node crossings and eclipse geometry.
        // --------------------------------------------------------

        if parentPlanetName.lowercased() == "earth" &&
            moon.name.lowercased() == "moon" {

            return EarthMoonAstronomy.displayPosition(
                for: moon,
                date: date,
                sceneUnitsPerKilometre: sceneUnitsPerKilometre
            )
        }

        // --------------------------------------------------------
        // All other moons
        //
        // Retain the existing generic Keplerian satellite model.
        // --------------------------------------------------------

        let julianDate = Astronomy.julianDate(for: date)
        let elapsedDays = julianDate - moon.epochJulianDate

        let meanAnomaly = Astronomy.normaliseDegrees(
            moon.meanAnomalyAtEpoch +
            moon.meanMotion * elapsedDays
        )

        let eccentricAnomaly = Astronomy.eccentricAnomaly(
            meanAnomaly: meanAnomaly,
            eccentricity: moon.eccentricity
        )

        let xOrbital = cos(eccentricAnomaly) - moon.eccentricity
        let yOrbital = sqrt(1.0 - moon.eccentricity * moon.eccentricity) * sin(eccentricAnomaly)

        let referencePlanePosition = positionInReferencePlane(
            xOrbital: xOrbital,
            yOrbital: yOrbital,
            moon: moon
        )

        let eclipticPosition = transformToEcliptic(
            referencePlanePosition,
            moon: moon,
            parentPlanetName: parentPlanetName,
            date: date
        )

        let displayRadius: Double

        if let sceneUnitsPerKilometre {

            displayRadius =
                moon.semiMajorAxisKM *
                sceneUnitsPerKilometre

        } else {

            displayRadius =
                Double(moon.position.x)
        }

        return SCNVector3(
            Float(eclipticPosition.x * displayRadius),
            Float(eclipticPosition.z * displayRadius),
            Float(eclipticPosition.y * displayRadius)
        )
    }

    // ============================================================
    // MARK: - ORBIT POINT
    //
    // Used by SolarSystemBuilder for drawing the orbit path.
    // ============================================================

    static func orbitPoint(
        for moon: Moon,
        parentPlanetName: String,
        eccentricAnomaly: Double,
        date: Date,
        sceneUnitsPerKilometre: Double? = nil
    ) -> SCNVector3 {

        let xOrbital = cos(eccentricAnomaly) - moon.eccentricity
        let yOrbital = sqrt(1.0 - moon.eccentricity * moon.eccentricity) * sin(eccentricAnomaly)

        let referencePlanePosition = positionInReferencePlane(
            xOrbital: xOrbital,
            yOrbital: yOrbital,
            moon: moon
        )

        let eclipticPosition = transformToEcliptic(
            referencePlanePosition,
            moon: moon,
            parentPlanetName: parentPlanetName,
            date: date
        )

        let displayRadius: Double

        if let sceneUnitsPerKilometre {

            displayRadius =
                moon.semiMajorAxisKM *
                sceneUnitsPerKilometre

        } else {

            displayRadius =
                Double(moon.position.x)
        }

        return SCNVector3(
            Float(eclipticPosition.x * displayRadius),
            Float(eclipticPosition.z * displayRadius),
            Float(eclipticPosition.y * displayRadius)
        )
    }

    // ============================================================
    // MARK: - POSITION IN MOON'S REFERENCE PLANE
    // ============================================================

    private static func positionInReferencePlane(
        xOrbital: Double,
        yOrbital: Double,
        moon: Moon
    ) -> SIMD3<Double> {

        let argumentPeriapsis = Astronomy.radians(
            moon.argumentPeriapsis
        )

        let inclination = Astronomy.radians(
            moon.inclination
        )

        let ascendingNode = Astronomy.radians(
            moon.ascendingNode
        )

        // Rotate by argument of periapsis.

        let x1 =
            xOrbital * cos(argumentPeriapsis) -
            yOrbital * sin(argumentPeriapsis)

        let y1 =
            xOrbital * sin(argumentPeriapsis) +
            yOrbital * cos(argumentPeriapsis)

        // Apply orbital inclination.

        let x2 = x1
        let y2 = y1 * cos(inclination)
        let z2 = y1 * sin(inclination)

        // Rotate by longitude of ascending node.

        let x3 =
            x2 * cos(ascendingNode) -
            y2 * sin(ascendingNode)

        let y3 =
            x2 * sin(ascendingNode) +
            y2 * cos(ascendingNode)

        return SIMD3<Double>(
            x3,
            y3,
            z2
        )
    }

    // ============================================================
    // MARK: - REFERENCE PLANE -> ECLIPTIC
    // ============================================================

    private static func transformToEcliptic(
        _ position: SIMD3<Double>,
        moon: Moon,
        parentPlanetName: String,
        date: Date
    ) -> SIMD3<Double> {

        switch moon.referencePlane {

        case .ecliptic:

            // Already expressed in the ecliptic reference frame.

            return position

        case .equatorial:

            // The elements are relative to the parent planet's
            // equatorial plane. Use the planet's actual pole.

            let pole = PlanetAstronomy.eclipticPoleVector(
                for: parentPlanetName,
                date: date
            )

            return rotateReferencePlaneToEcliptic(
                position,
                pole: SIMD3<Double>(
                    Double(pole.x),
                    Double(pole.z),
                    Double(pole.y)
                )
            )

        case .laplace:

            // The elements are relative to the moon's Laplace plane.
            // The stored pole is supplied as equatorial RA/Dec.

            let pole = equatorialPoleToEcliptic(
                rightAscension: moon.referencePlaneRightAscension,
                declination: moon.referencePlaneDeclination
            )

            return rotateReferencePlaneToEcliptic(
                position,
                pole: pole
            )
        }
    }

    // ============================================================
    // MARK: - EQUATORIAL POLE -> ECLIPTIC POLE
    // ============================================================

    private static func equatorialPoleToEcliptic(
        rightAscension: Double,
        declination: Double
    ) -> SIMD3<Double> {

        let ra = Astronomy.radians(
            rightAscension
        )

        let dec = Astronomy.radians(
            declination
        )

        let xEquatorial =
            cos(dec) * cos(ra)

        let yEquatorial =
            cos(dec) * sin(ra)

        let zEquatorial =
            sin(dec)

        let obliquity =
            Astronomy.radians(
                23.4392911
            )

        let xEcliptic =
            xEquatorial

        let yEcliptic =
            yEquatorial * cos(obliquity) +
            zEquatorial * sin(obliquity)

        let zEcliptic =
            -yEquatorial * sin(obliquity) +
            zEquatorial * cos(obliquity)

        return simd_normalize(
            SIMD3<Double>(
                xEcliptic,
                yEcliptic,
                zEcliptic
            )
        )
    }

    // ============================================================
    // MARK: - REFERENCE PLANE ROTATION
    // ============================================================

    private static func rotateReferencePlaneToEcliptic(
        _ position: SIMD3<Double>,
        pole: SIMD3<Double>
    ) -> SIMD3<Double> {

        let targetPole =
            simd_normalize(
                pole
            )

        // Local +Z is the normal of the orbital reference plane.

        let localPole =
            SIMD3<Double>(
                0.0,
                0.0,
                1.0
            )

        let dotProduct =
            max(
                -1.0,
                min(
                    1.0,
                    simd_dot(
                        localPole,
                        targetPole
                    )
                )
            )

        if dotProduct > 0.999999 {
            return position
        }

        if dotProduct < -0.999999 {

            let quaternion =
                simd_quatd(
                    angle: Double.pi,
                    axis: SIMD3<Double>(
                        1.0,
                        0.0,
                        0.0
                    )
                )

            return quaternion.act(
                position
            )
        }

        let rotationAxis =
            simd_normalize(
                simd_cross(
                    localPole,
                    targetPole
                )
            )

        let rotationAngle =
            acos(
                dotProduct
            )

        let quaternion =
            simd_quatd(
                angle: rotationAngle,
                axis: rotationAxis
            )

        return quaternion.act(
            position
        )
    }

    // ============================================================
    // MARK: - ROTATION
    // ============================================================

    static func rotationAngle(
        for moon: Moon,
        date: Date,
        epoch: Date
    ) -> CGFloat {

        guard moon.dayLength != 0 else {
            return 0
        }

        let elapsedDays =
            date.timeIntervalSince(
                epoch
            ) / 86400.0

        let rotations =
            elapsedDays /
            moon.dayLength

        return CGFloat(
            rotations
                .truncatingRemainder(
                    dividingBy: 1.0
                ) *
            Double.pi *
            2.0
        )
    }
}
