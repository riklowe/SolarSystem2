//
//  Asteroid.swift
//  SolarSystem2
//

import Foundation
import CoreGraphics

struct Asteroid {
    let name: String
    let displayRadius: CGFloat
    let bodyRadius: CGFloat
    let image: String?

    // JPL osculating orbital elements
    let epochJulianDate: Double
    let semiMajorAxis: Double
    let eccentricity: Double
    let inclination: Double
    let argumentPerihelion: Double
    let ascendingNode: Double
    let meanAnomalyAtEpoch: Double
    let meanMotion: Double

    // Physical rotation
    let rotationPeriodDays: Double
}
