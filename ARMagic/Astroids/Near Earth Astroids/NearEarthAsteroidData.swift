//
//  NearEarthAsteroidData.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation

enum NearEarthAsteroidData {

    static let apophis = NearEarthAsteroid(
        name: "Apophis",
        designation: "99942 Apophis",
        diameterKM: 0.340,
        isPotentiallyHazardous: true,
        isImpactor: false,
        encounterDate: makeUTCDate(year: 2029, month: 4, day: 13, hour: 21, minute: 46),
        encounterDistanceKM: 38_012.0,
        rotationPeriodHours: nil,
        ephemerisResourceName: "apophis"
    )

    static let all: [NearEarthAsteroid] = [
        apophis
    ]

    private static func makeUTCDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {

        var components = DateComponents()

        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)

        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0

        return components.date!
    }
}
