//
//  Asteroid.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

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
