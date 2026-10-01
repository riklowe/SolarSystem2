//
//  NearEarthAsteroid.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation

struct NearEarthAsteroid {

    let name: String
    let designation: String

    let diameterKM: Double

    let isPotentiallyHazardous: Bool
    let isImpactor: Bool

    let encounterDate: Date
    let encounterDistanceKM: Double

    let rotationPeriodHours: Double?

    let ephemerisResourceName: String
}
