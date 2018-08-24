//
//  DwarfPlanetAstronomy.swift
//  SolarSystem2
//

import Foundation
import SceneKit

enum DwarfPlanetAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    static func orbitalPosition(for dwarfPlanet: DwarfPlanet, date: Date) -> SCNVector3 {

        let julianDate = Astronomy.julianDate(for: date)

        let daysSinceEpoch = julianDate - dwarfPlanet.epochJulianDate

        var meanAnomaly = dwarfPlanet.meanAnomalyAtEpoch + dwarfPlanet.meanMotion * daysSinceEpoch
        meanAnomaly = normalizeDegrees(meanAnomaly)

        let meanAnomalyRadians = degreesToRadians(meanAnomaly)
        let eccentricAnomaly = solveKepler(meanAnomaly: meanAnomalyRadians, eccentricity: dwarfPlanet.eccentricity)

        let a = Double(dwarfPlanet.displaySemiMajorAxis)
        let e = dwarfPlanet.eccentricity

        let xOrbital = a * (cos(eccentricAnomaly) - e)
        let yOrbital = a * sqrt(1.0 - e * e) * sin(eccentricAnomaly)

        let argumentPeriapsis = degreesToRadians(dwarfPlanet.argumentPeriapsis)
        let ascendingNode = degreesToRadians(dwarfPlanet.ascendingNode)
        let inclination = degreesToRadians(dwarfPlanet.inclination)

        let cosOmega = cos(ascendingNode)
        let sinOmega = sin(ascendingNode)
        let cosArgument = cos(argumentPeriapsis)
        let sinArgument = sin(argumentPeriapsis)
        let cosInclination = cos(inclination)
        let sinInclination = sin(inclination)

        let x = (cosOmega * cosArgument - sinOmega * sinArgument * cosInclination) * xOrbital
              + (-cosOmega * sinArgument - sinOmega * cosArgument * cosInclination) * yOrbital

        let y = (sinOmega * cosArgument + cosOmega * sinArgument * cosInclination) * xOrbital
              + (-sinOmega * sinArgument + cosOmega * cosArgument * cosInclination) * yOrbital

        let z = (sinArgument * sinInclination) * xOrbital
              + (cosArgument * sinInclination) * yOrbital

        // Astronomy ecliptic XYZ -> SceneKit XZY.
        return SCNVector3(Float(x), Float(z), Float(y))
    }

    static func orbitPoint(for dwarfPlanet: DwarfPlanet, eccentricAnomaly: Double) -> SCNVector3 {
        let a = Double(dwarfPlanet.displaySemiMajorAxis)
        let e = dwarfPlanet.eccentricity

        let xOrbital = a * (cos(eccentricAnomaly) - e)
        let yOrbital = a * sqrt(1.0 - e * e) * sin(eccentricAnomaly)

        let argumentPeriapsis = degreesToRadians(dwarfPlanet.argumentPeriapsis)
        let ascendingNode = degreesToRadians(dwarfPlanet.ascendingNode)
        let inclination = degreesToRadians(dwarfPlanet.inclination)

        let cosOmega = cos(ascendingNode)
        let sinOmega = sin(ascendingNode)
        let cosArgument = cos(argumentPeriapsis)
        let sinArgument = sin(argumentPeriapsis)
        let cosInclination = cos(inclination)
        let sinInclination = sin(inclination)

        let x = (cosOmega * cosArgument - sinOmega * sinArgument * cosInclination) * xOrbital
              + (-cosOmega * sinArgument - sinOmega * cosArgument * cosInclination) * yOrbital

        let y = (sinOmega * cosArgument + cosOmega * sinArgument * cosInclination) * xOrbital
              + (-sinOmega * sinArgument + cosOmega * cosArgument * cosInclination) * yOrbital

        let z = (sinArgument * sinInclination) * xOrbital
              + (cosArgument * sinInclination) * yOrbital

        return SCNVector3(Float(x), Float(z), Float(y))
    }

    private static func solveKepler(meanAnomaly: Double, eccentricity: Double) -> Double {
        var eccentricAnomaly = meanAnomaly

        for _ in 0..<20 {
            let delta = (eccentricAnomaly - eccentricity * sin(eccentricAnomaly) - meanAnomaly) /
                        (1.0 - eccentricity * cos(eccentricAnomaly))

            eccentricAnomaly -= delta

            if abs(delta) < 1.0e-12 {
                break
            }
        }

        return eccentricAnomaly
    }

    private static func normalizeDegrees(_ degrees: Double) -> Double {
        var result = degrees.truncatingRemainder(dividingBy: 360.0)
        if result < 0.0 { result += 360.0 }
        return result
    }

    private static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180.0
    }
}
