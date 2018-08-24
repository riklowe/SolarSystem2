//
//  Moon.swift
//  SolarSystem2
//

import Foundation
import SceneKit

enum MoonReferencePlane {
    case ecliptic
    case equatorial
    case laplace
}

struct Moon {
    let name: String
    let radius: CGFloat
    let image: String
    let position: SCNVector3

    // Physical rotation
    let dayLength: TimeInterval

    // Orbital elements
    let epochJulianDate: Double
    let semiMajorAxisKM: Double
    let eccentricity: Double
    let inclination: Double
    let ascendingNode: Double
    let argumentPeriapsis: Double
    let meanAnomalyAtEpoch: Double
    let meanMotion: Double

    // Reference plane for orbital elements
    let referencePlane: MoonReferencePlane
    let referencePlaneRightAscension: Double
    let referencePlaneDeclination: Double

    let retrograde: Bool
}
