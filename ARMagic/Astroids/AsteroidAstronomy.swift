//
//  AsteroidAstronomy.swift
//  SolarSystem2
//

import Foundation
import SceneKit

enum AsteroidAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    static func orbitalPosition(for asteroid: Asteroid, date: Date) -> SCNVector3 {

        let julianDate = Astronomy.julianDate(for: date)
        let elapsedDays = julianDate - asteroid.epochJulianDate

        let meanAnomaly = Astronomy.normaliseDegrees(asteroid.meanAnomalyAtEpoch + asteroid.meanMotion * elapsedDays)
        let E = Astronomy.eccentricAnomaly(meanAnomaly: meanAnomaly, eccentricity: asteroid.eccentricity)

        let xOrbital = cos(E) - asteroid.eccentricity
        let yOrbital = sqrt(1.0 - asteroid.eccentricity * asteroid.eccentricity) * sin(E)

        let argument = Astronomy.radians(asteroid.argumentPerihelion)
        let inclination = Astronomy.radians(asteroid.inclination)
        let ascendingNode = Astronomy.radians(asteroid.ascendingNode)

        let x1 = xOrbital * cos(argument) - yOrbital * sin(argument)
        let y1 = xOrbital * sin(argument) + yOrbital * cos(argument)

        let x2 = x1
        let y2 = y1 * cos(inclination)
        let z2 = y1 * sin(inclination)

        let x3 = x2 * cos(ascendingNode) - y2 * sin(ascendingNode)
        let y3 = x2 * sin(ascendingNode) + y2 * cos(ascendingNode)

        return SCNVector3(Float(x3 * Double(asteroid.displayRadius)), Float(z2 * Double(asteroid.displayRadius)), Float(y3 * Double(asteroid.displayRadius)))
    }

    static func rotationAngle(for asteroid: Asteroid, date: Date, epoch: Date) -> CGFloat {

        guard asteroid.rotationPeriodDays > 0 else { return 0 }

        let elapsedDays = date.timeIntervalSince(epoch) / 86400.0
        let rotations = elapsedDays / asteroid.rotationPeriodDays

        return CGFloat(rotations.truncatingRemainder(dividingBy: 1.0) * Double.pi * 2.0)
    }
}
