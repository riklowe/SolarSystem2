//
//  NearEarthAsteroid.swift
//  ARMagic
//
//  Created by Richard Lowe on 30/09/2026.
//  Copyright © 2026 Alex Nagy. All rights reserved.
//


//
//  NearEarthAsteroid.swift
//  SolarSystem2
//

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