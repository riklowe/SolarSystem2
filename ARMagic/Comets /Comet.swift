//
//  Comet.swift
//  SolarSystem2
//
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

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
