//
//  NearEarthEphemeris.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation
import simd

struct NearEarthEphemerisPoint: Codable {

    let julianDate: Double

    let xAU: Double
    let yAU: Double
    let zAU: Double

    let vxAUPerDay: Double
    let vyAUPerDay: Double
    let vzAUPerDay: Double

    var positionAU: SIMD3<Double> {
        SIMD3<Double>(xAU, yAU, zAU)
    }

    var velocityAUPerDay: SIMD3<Double> {
        SIMD3<Double>(vxAUPerDay, vyAUPerDay, vzAUPerDay)
    }
}

struct NearEarthEphemeris: Codable {

    let designation: String
    let source: String
    let referenceFrame: String
    let centre: String

    let points: [NearEarthEphemerisPoint]
}
