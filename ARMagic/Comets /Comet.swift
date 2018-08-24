//
//  Comet.swift
//  SolarSystem2
//

import Foundation
import SceneKit

struct Comet {

    let name: String

    // Visual properties
    let nucleusRadius: CGFloat
    let displaySemiMajorAxis: Float

    // Osculating heliocentric orbital elements
    let epochJulianDate: Double
    let semiMajorAxisAU: Double
    let eccentricity: Double
    let inclination: Double
    let ascendingNode: Double
    let argumentPeriapsis: Double
    let meanAnomalyAtEpoch: Double
    let meanMotion: Double
}
