//
//  CometAstronomy.swift
//  SolarSystem2
//

import Foundation
import SceneKit

enum CometAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - ORBITAL POSITION
    // ============================================================

    static func orbitalPosition(for comet: Comet, date: Date) -> SCNVector3 {

        let julianDate = Astronomy.julianDate(for: date)
        let daysSinceEpoch = julianDate - comet.epochJulianDate

        var meanAnomaly = comet.meanAnomalyAtEpoch + comet.meanMotion * daysSinceEpoch
        meanAnomaly = normalizeDegrees(meanAnomaly)

        let meanAnomalyRadians = degreesToRadians(meanAnomaly)

        let eccentricAnomaly = solveKepler(
            meanAnomaly: meanAnomalyRadians,
            eccentricity: comet.eccentricity
        )

        return position(
            for: comet,
            eccentricAnomaly: eccentricAnomaly
        )
    }

    // ============================================================
    // MARK: - ORBIT POINT
    // ============================================================

    static func orbitPoint(for comet: Comet, eccentricAnomaly: Double) -> SCNVector3 {
        return position(
            for: comet,
            eccentricAnomaly: eccentricAnomaly
        )
    }

    // ============================================================
    // MARK: - HELIOCENTRIC DISTANCE
    // ============================================================

    static func heliocentricDistanceAU(for comet: Comet, date: Date) -> Double {

        let julianDate = Astronomy.julianDate(for: date)
        let daysSinceEpoch = julianDate - comet.epochJulianDate

        var meanAnomaly = comet.meanAnomalyAtEpoch + comet.meanMotion * daysSinceEpoch
        meanAnomaly = normalizeDegrees(meanAnomaly)

        let eccentricAnomaly = solveKepler(
            meanAnomaly: degreesToRadians(meanAnomaly),
            eccentricity: comet.eccentricity
        )

        return comet.semiMajorAxisAU * (1.0 - comet.eccentricity * cos(eccentricAnomaly))
    }

    // ============================================================
    // MARK: - POSITION CONVERSION
    // ============================================================

    private static func position(for comet: Comet, eccentricAnomaly: Double) -> SCNVector3 {

        let a = Double(comet.displaySemiMajorAxis)
        let e = comet.eccentricity

        let xOrbital = a * (cos(eccentricAnomaly) - e)
        let yOrbital = a * sqrt(1.0 - e * e) * sin(eccentricAnomaly)

        let argumentPeriapsis = degreesToRadians(comet.argumentPeriapsis)
        let ascendingNode = degreesToRadians(comet.ascendingNode)
        let inclination = degreesToRadians(comet.inclination)

        let cosOmega = cos(ascendingNode)
        let sinOmega = sin(ascendingNode)

        let cosArgument = cos(argumentPeriapsis)
        let sinArgument = sin(argumentPeriapsis)

        let cosInclination = cos(inclination)
        let sinInclination = sin(inclination)

        let x =
            (cosOmega * cosArgument - sinOmega * sinArgument * cosInclination) * xOrbital +
            (-cosOmega * sinArgument - sinOmega * cosArgument * cosInclination) * yOrbital

        let y =
            (sinOmega * cosArgument + cosOmega * sinArgument * cosInclination) * xOrbital +
            (-sinOmega * sinArgument + cosOmega * cosArgument * cosInclination) * yOrbital

        let z =
            (sinArgument * sinInclination) * xOrbital +
            (cosArgument * sinInclination) * yOrbital

        // Astronomy coordinates -> SceneKit coordinates
        return SCNVector3(
            Float(x),
            Float(z),
            Float(y)
        )
    }

    // ============================================================
    // MARK: - KEPLER SOLVER
    // ============================================================

    private static func solveKepler(meanAnomaly: Double, eccentricity: Double) -> Double {

        // Highly eccentric comets converge better starting near π.
        var eccentricAnomaly = eccentricity > 0.8 ? Double.pi : meanAnomaly

        for _ in 0..<30 {

            let delta =
                (eccentricAnomaly -
                 eccentricity * sin(eccentricAnomaly) -
                 meanAnomaly) /
                (1.0 - eccentricity * cos(eccentricAnomaly))

            eccentricAnomaly -= delta

            if abs(delta) < 1.0e-12 {
                break
            }
        }

        return eccentricAnomaly
    }

    // ============================================================
    // MARK: - HELPERS
    // ============================================================

    private static func normalizeDegrees(_ degrees: Double) -> Double {
        var result = degrees.truncatingRemainder(dividingBy: 360.0)
        if result < 0.0 { result += 360.0 }
        return result
    }

    private static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
}
