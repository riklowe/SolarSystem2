//
//  DwarfPlanet.swift
//  SolarSystem2
//

import Foundation
import SceneKit

struct DwarfPlanet {

    let name: String
    let radius: CGFloat
    let image: String?
    let displaySemiMajorAxis: Float

    let epochJulianDate: Double
    let semiMajorAxisAU: Double
    let eccentricity: Double
    let inclination: Double
    let ascendingNode: Double
    let argumentPeriapsis: Double
    let meanAnomalyAtEpoch: Double
    let meanMotion: Double
}
